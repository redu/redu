class CoursesController < BaseController
  before_filter :login_required, :except => [:index]
  
  def favorites
    
    if params[:from] == 'favorites'
      @taskbar = "favorites/taskbar"
    else
      @taskbar = "courses/taskbar_index"
    end
    
    @courses = Course.paginate(:all, 
    :joins => :favorites,
    :conditions => ["favorites.favoritable_type = 'Course' AND favorites.user_id = ? AND courses.id = favorites.favoritable_id", current_user.id], 
    :page => params[:page], :order => 'created_at DESC', :per_page => AppConfig.items_per_page)
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
  
  
  def rate
    @course = Course.find(params[:id])
    @course.rate(params[:stars], current_user, params[:dimension])
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}course-#{@course.id}"
    
    render :update do |page|
      page.replace_html id, ratings_for(@course, :wrap => false, :dimension => params[:dimension])
      page.visual_effect :highlight, id
    end
  end
  
  
  # Lista todos os recursos existentes para relacionar com
  def list_resources
    @resources = Resource.all
    @course = params[:id]
  end
  
  # Adicionar um recurso na aula.
  def add_resource
    @selected_resources = params[:resource][:id]
    @course = Course.find(params[:id])
    
    if @course
      @selected_resources.each do |c| 
        @resource = Resource.find(c)
        @course.resources << @resource
      end
      
      if @course.save
        flash[:notice] = 'Recurso(s) adicionada(s).'
      else
        flash[:error] = 'Algum problema aconteceu!'
      end
    else
      flash[:error] = 'Aula inválida.'
    end  
    
    respond_to do |format|
      format.html { redirect_to(@course) }
    end
    
  end
  
  def get_query(sort, page)
    
    case sort
      
      when '1' # Data
      @courses = Course.paginate :conditions => ["state LIKE ?", "approved"], :include => :owner, :page => page, :order => 'created_at DESC', :per_page => AppConfig.items_per_page
      when '2' # Avaliações
      @courses = Course.paginate :conditions => ["state LIKE ?", "approved"], :include => :owner, :page => page, :order => 'rating_average DESC', :per_page => AppConfig.items_per_page
      when '3' # Visualizações
      @courses = Course.paginate :conditions => ["state LIKE ?", "approved"], :include => :owner, :page => page, :order => 'view_count DESC', :per_page => AppConfig.items_per_page
      when '4' # Título
      @courses = Course.paginate :conditions => ["state LIKE ?", "approved"], :include => :owner, :page => page, :order => 'name DESC', :per_page => AppConfig.items_per_page
    else
      @courses = Course.paginate :conditions => ["state LIKE ?", "approved"], :include => :owner, :page => page, :order => 'created_at DESC', :per_page => AppConfig.items_per_page
    end
    
  end
  
  
  # GET /courses
  # GET /courses.xml
  def index
    
    if params[:user_id] # TODO garantir que é sempre login e nao id?
      @user = User.find_by_login(params[:user_id])
      @courses = @user.courses.paginate :page => params[:page], :per_page => AppConfig.items_per_page
      
      respond_to do |format|
        format.html { render :action => "user_courses"} 
        format.xml  { render :xml => @user.courses }
      end
    else 
      
      @sort_by = params[:sort_by]
      #@order = params[:order]
      @courses = get_query(params[:sort_by], params[:page]) 
      @popular_tags = Course.tag_counts
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @courses }
      end
    end
  end
  
  # GET /courses/1
  # GET /courses/1.xml
  def show
    
    @course = Course.find(params[:id])
   # if not @course.can_be_deleted_by(current_user)
   #   flash[:error] = "Você não tem acesso a este vídeo"
   #   redirect_to courses_path # TODO voltar para link anterior
   # else 
      #comentários
      @comments  = @course.comments.find(:all, :limit => 10, :order => 'created_at DESC')
      
      # anotações
      @annotation = @course.has_annotations_by(current_user) 
      @annotation = Annotation.new unless @annotation
      
      #relacionados
      related_name = @course.name
      @related_courses = Course.find(:all,:conditions => ["name LIKE ? AND id NOT LIKE ?","%#{related_name}%", @course.id] , :limit => 3, :order => 'created_at DESC')
      
      # atualiza número de exibições TODO cache
      @course.update_attribute(:view_count, @course.view_count + 1) #TODO performance
      
      Log.log_activity(@course, 'show', current_user)#TODO se usuario nao comprou não logar atividade

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @course }
      end
   # end
    
  end
  
  def view
    @course = Course.find(params[:id])
    
    @comments  = @course.comments.find(:all, :limit => 10, :order => 'created_at DESC')
    
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @course }
    end
    
    
  end
  
  # GET /courses/new
  # GET /courses/new.xml
  def new
    @course = Course.new
    @course.build_price
    3.times { @course.resources.build }
    #TODO mostrar apenas as escolas nas quais o usuario tem permissao de postagem
    #if params[:school]
    
    @schools = current_user.schools
  end
  
  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
    #TODO mostrar apenas as escolas nas quais o usuario tem permissao de postagem
    @schools = current_user.schools 
  end
  
  
  # POST /courses
  # POST /courses.xml
  def create
    
    @course = Course.new(params[:course])
	if @course.external_resource_type.eql?('youtube')
		capture = @course.external_resource.scan(/watch\?v=([a-zA-Z0-9]*)/o)[0][0]
		puts capture.inspect
		@course.external_resource = capture
	end
    @course.owner = current_user
    
    respond_to do |format|
      
      if @course.save!
        @course.convert
        
        if params[:post_to]
          SchoolAsset.create({:asset_type => "Course", :asset_id => @course.id, :school_id => params[:post_to].to_i})
          #@school = School.find(params[:post_to].to_i)
          #@school.assets << @course
          #@school.update_attribute(:assets, @school.assets)
        end
        
        Log.log_activity(@course, 'create', current_user) # só aparece quando é aprovada
        
        flash[:notice] = 'Aula foi criada com sucesso e está em processo de moderação.'
        format.html { 
          #redirect_to(@course)
          redirect_to waiting_user_courses_path(current_user.id)
        }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else  
        format.html { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    @course = Course.find(params[:id])
    
     Log.log_activity(@course, 'update', @course.owner)
    
    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Curso atualizado com sucesso.'
        format.html { redirect_to(@course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    flash[:notice] = 'A aula foi removida'
    
    respond_to do |format|
      format.html { redirect_to(courses_url) }
      format.xml  { head :ok }
    end
  end
  
  
  #Buy one course  
  def buy
    @course = Course.find(params[:id])
    
    if not current_user.has_access_to_course(@course)
      
      if current_user.has_credits_for_course(@course)
        #o nome dessa variável, deixar como acquisition
        @acquisition = Acquisition.new
        @acquisition.acquired_by_type = "User"
        @acquisition.acquired_by_id = current_user.id
        @acquisition.value =  Course.price_of_acquisition(@course.id)
        @acquisition.course = @course
        
        if @acquisition.save
          flash[:notice] = 'A aula foi comprada!'
          redirect_to @course
        end
      else
        flash[:notice] = 'Você não tem créditos suficientes para comprar esta aula. Recarrege agora!'
        # TODO passar como parametro url da aula para retornar após compra
        redirect_to credits_path(:course_id => @course.id)
      end
    else
      flash[:notice] = 'Você já possui acesso a esta aula!'
      redirect_to @course
    end
  end
  
  
  
  
  def approve
    @course = Course.find(params[:id])
    @course.approve!
    
    Log.log_activity(@course, 'create', @course.owner)
    
    flash[:notice] = 'A aula foi aprovada!'
    redirect_to pending_courses_path
  end
  
  def disapprove
    @course = Course.find(params[:id])
    @course.disapprove!
    flash[:notice] = 'A aula não foi aprovada!'
    redirect_to pending_courses_path
  end
  
  
  # LISTAGENS
  
  def pending
    @courses = Course.paginate(:conditions => ["published = 1 AND state LIKE ?", "waiting"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      format.xml  { render :xml => @resources }
    end
    
  end
  
  
  def published
    @courses = Course.paginate(:conditions => ["owner = ? AND published = 1 AND state LIKE ?", params[:user_id], "approved"], 
  		:include => :owner, 
  		:page => params[:page], 
  		:order => 'updated_at DESC', 
  		:per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      format.xml  { render :xml => @resources }
    end
  end
  
  def unpublished
    @courses = Course.paginate(:conditions => ["owner = ? AND published = 0", params[:user_id]], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      format.xml  { render :xml => @resources }
    end
  end
  
  def waiting
    @courses = Course.paginate(:conditions => ["owner = ? AND published = 1 AND state LIKE ?", params[:user_id], "waiting"], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      format.xml  { render :xml => @resources }
    end
  end
  
end
