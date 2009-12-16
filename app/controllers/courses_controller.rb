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
=begin  
  def put_comment
    
    if current_user
      
      thecomment = params[:comment]
      @commentable = Course.find(params[:id])
      @commentable.comments.create(:comment => thecomment, :user => current_user)
      
    else
      flash[:error] = 'Usuário não logado'
    end
    
    respond_to do |format|
      format.html { redirect_to(@commentable) }
    end
    
  end

  # Verificar as validações do model 'comment'
  def add_comment
    
    @course = Course.find(params[:id])
    @comment = Comment.new
    
    if @course
      
      @course.comments << @comment
      
      if @course.save
        flash[:notice] = 'Comentário adicionado.'
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
=end 
  
  # Lista todos os recursos existentes para relacionar com
  def list_resources
    @resources = Resource.all
    @course = params[:id]
  end
  
  
  # Adicionar um recurso na aula.
  def add_resource
    @selected_resources = params[:resource][:id]
    puts @selected_resources
    
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
		redirect_to :controller => 'create_course', :action => 'step1'
  end
  
  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end
  
=begin
  def check_name_subject(course)
    @subjects = Subject.all
    while not @subjects.nil?
    course 
  end
=end  
  
  # POST /courses
  # POST /courses.xml
  def create
    
    # @course = course.create!(params[:course])
    
#modificações feitas em 12 de dez
    
    @course = Course.new(params[:course])
    @course.owner = current_user
    
    if params[:price_user]
      @price_user = Courseprice.new  
      @price_user.course = @course
      @price_user.key_number = 1
      @price_user.price = params[:price_user].to_f
      @price_user.save
    end      
    
    if params[:price_500]
      @price_500 = Courseprice.new  
      @price_500.course = @course
      @price_500.key_number = 500
      @price_500.price = params[:price_500].to_f
      @price_500.save
    end 
    
    #fim das modificações
    
    
    
    respond_to do |format|
      if @course.save
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
    
    if params[:price_user]
      @price_user = Courseprice.new  
      @price_user.course = @course
      @price_user.key_number = 1
      @price_user.price = params[:price_user].to_f
      @price_user.save
    end      
    
    if params[:price_500]
      @price_500 = Courseprice.new  
      @price_500.course = @course
      @price_500.key_number = 500
      @price_500.price = params[:price_500].to_f
      @price_500.save
    end
    
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
  
end
