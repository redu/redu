class CoursesController < BaseController
  
  
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
    @courses = Course.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end
  
  # GET /courses/1
  # GET /courses/1.xml
  def show
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
		params[:course][:main_resource_attributes][:owner] = current_user
		
    @course = Course.new(params[:course])
    
    respond_to do |format|
    	
      if @course.save
        @course.main_resource.convert
        flash[:notice] = 'Aula foi criada com sucesso.'
        format.html { redirect_to(@course) }
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
    @acquisition.produto = @course
    
    if @acquisition.save
      flash[:notice] = "A aula foi comprada!"
      redirect_to @course
    end
  end
  
  def published
  	@courses = Course.paginate(:conditions => ["owner = ? AND published = 1", params[:user_id]], 
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
