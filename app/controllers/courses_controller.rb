class CoursesController < BaseController
  before_filter :login_required, :except => [:index]
  CourseObserver.observed_class
  
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
  
  
  # GET /courses
  # GET /courses.xml
  def index
    @courses = Course.all(:conditions => ["state LIKE ?", "approved"])
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
  
  # GET /courses/1
  # GET /courses/1.xml
  def show
    
    @course = Course.find(params[:id])
    if current_user.owner.eql?(@course.owner)
      @comments  = @course.comments.find(:all, :limit => 10, :order => 'created_at DESC')
      
      Log.create(:table => 'course',
      :action => 'show',
      :actor_name => current_user.login,
      :actor_id => current_user.id,
      :object_name => @course.name,
      :object_id => @course.id,
      :comment => 'Aula Mostrada...')
      
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @course }
      end
    else
      flash[:notice] = 'Você ainda não comprou essa aula!'
      redirect_to '/courses/'
    end
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
  end
  
  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end
  
  
  # POST /courses
  # POST /courses.xml
  def create
    params[:course][:owner] = current_user
    
    @course = Course.new(params[:course])
    
    respond_to do |format|
      
      if @course.save
        @course.convert
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
    
    #o nome dessa variável, deixar como acquisition
    @acquisition = Acquisition.new
   	'''
    if current_user.is_school_admin?
      aquisicao.entity = "School"
      aquisicao.entity_id = current_user.school # TODO implementar admin de uma unica escola
    end
    '''
    @acquisition.acquired_by_type = "User"
    @acquisition.acquired_by_id = current_user.id
    @acquisition.course = @course
    #olhar ainda esse current_user.owner = 1
    current_user.owner = 1
    
    if @acquisition.save
      flash[:notice] = 'A aula foi comprada!'
      redirect_to @course
    end
  end
  
  
  def approve
    @course = Course.find(params[:id])
    @course.approve!
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
