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
    @course = Course.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @course }
    end
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
    
    @course = Course.new(params[:course])
    @course.owner = current_user
    
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
    
    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Course was successfully updated.'
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
    
    respond_to do |format|
      format.html { redirect_to(courses_url) }
      format.xml  { head :ok }
    end
  end
end
