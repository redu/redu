class CoursesController < BaseController
  before_filter :login_required, :except => [:index]
  
  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:new, :edit, :update])
  
  
  def download_attachment
    @attachment = CourseResource.find(params[:res_id])
   # puts @attachment.attachment.path + ' e ' + @attachment.attachment.content_type
    send_file @attachment.attachment.path, :type=> @attachment.attachment.content_type, :x_sendfile=>true
  end
  
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
  
  def sort_lesson 
#    @iclass = InteractiveClass.find(params[:iclass])
#    @iclass.lessons.each do |lesson|
#      lesson.position = params[:topic_list].index(lesson.id.to_s) + 1
#      lesson.save
#    end
#    render :nothing => true
    
    params['topic_list'].each_with_index do |id, index|
    Lesson.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true

  end
  
  def search
    
    @courses = Course.find_tagged_with(params[:query])
    @courses += Course.find(:all, :conditions => ["name LIKE ?", "%" + params[:query] + "%"])
    
    respond_to do |format|
      format.js do
          render :update do |page| 
            page.replace_html 'all_list', 
           :partial => 'courses/item', :collection => @courses, :as => :course
            page.replace_html 'title_list', "Resultados para: \"#{params[:query]}\""
          end
      end
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
    
      @course = Course.find(params[:id], :include => {:interactive_class => [:lessons]})
    
    
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
      
      Log.log_activity(@course, 'show', current_user, @school)#TODO se usuario nao comprou não logar atividade

      respond_to do |format|
        if @course.course_type == 'page'
          format.html {render 'show_page'}
        elsif @course.course_type == 'interactive'
          @lessons = Lesson.all(:conditions => ['interactive_class_id = ?',@course.interactive_class.id ], :order => 'position ASC')
           format.html {render 'show_interactive'}
        else # TODO colocar type == seminar / estamos considerando que o resto é seminário
          format.html {render 'show_seminar'}
        end
        
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
    
    case params[:step]
      when "2"
        
         @course = Course.find(session[:course_id])
        
        if @course.course_type == 'seminar'
        
         # @course = Course.find(session[:course_id])
        
          3.times { @course.resources.build }
        
          @course.enable_validation_group :step2_seminar
          @edit = false
          render "step2_seminar" and return
        
        elsif @course.course_type == 'interactive'
          @interactive_class = InteractiveClass.new
          
           3.times { @interactive_class.resources.build }
           @interactive_class.lessons.build
          
          render "step2_interactive" and return
        
        elsif @course.course_type == 'page'
          @page = Page.new
          render "step2_page" and return
        
        end
        
      when "3"
        @course = Course.find(session[:course_id])
        # @course.build_price
        @schools = current_user.schools
        
        #@course_type = params[:course_type]
        
         @course.enable_validation_group :step3
        render "step3" and return
        
      else # 1
     # session[:course_id] = nil
        #if params[:prev] == '2' #voltou
        #  
        #end
     
     
        if session[:course_id]
          @course = Course.find(session[:course_id])
        else
          @course = Course.new
        end
      
        @course.enable_validation_group :step1
        render "step1" and return
    end
    
  
  end
  
  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
    
    
    respond_to do |format|
        if @course.course_type == 'page'
          format.html {render 'edit_page'}
        elsif @course.course_type == 'interactive'
          @interactive_class = @course.interactive_class
          #@lessons = Lesson.all(:conditions => ['interactive_class_id = ?',@course.interactive_class.id ], :order => 'position ASC')
           format.html {render 'edit_interactive'}
        else # TODO colocar type == seminar / estamos considerando que o resto é seminário
          format.html {render 'edit_seminar'}
        end
        
        format.xml  { render :xml => @course }
      end
    
  end
  
  
  # POST /courses
  # POST /courses.xml
  def create

    case params[:step]
      when "1"
          @course = Course.new(params[:course])
          @course.owner = current_user
          @course.enable_validation_group :step1
          
          respond_to do |format|
            if @course.save
              
              session[:course_id] = @course.id
              
              format.html { 
                redirect_to :action => :new, :step => "2"
              }
            else  
              format.html { render "step1" }
            end
          end
          
      
      when "2"
        @course = Course.find(session[:course_id])
        
        if @course.course_type == 'seminar'
          
          if @course.external_resource_type.eql?('youtube')
            capture = @course.external_resource.scan(/watch\?v=([a-zA-Z0-9]*)/o)[0][0]
            #puts capture.inspect
            @course.external_resource = capture
          elsif @course.external_resource_type.eql?('youtube')
            @course.convert # converter aqui tem problema? acho que nao..
          end
          
          respond_to do |format|
            
            if @course.update_attributes(params[:course])
              
              
              format.html { 
                 redirect_to :action => :new , :course_type => params[:course_type], :step => "3"
              }
            else  
              @edit = false
              format.html { render "step2_seminar" }
            end
          end
          
          
        elsif @course.course_type == 'interactive'
          @interactive_class = InteractiveClass.new(params[:interactive_class])
          @interactive_class.course = @course
          
           respond_to do |format|
            
            if @interactive_class.save
              
              format.html { 
                 redirect_to :action => :new , :course_type => params[:course_type], :step => "3"
              }
            else  
              format.html { render "step2_interactive" }
            end
          end
          
        elsif @course.course_type == 'page'
          
          @page = Page.new(params[:page])
          @page.course = @course
          
           respond_to do |format|
            
            if @page.save
              
              format.html { 
                 redirect_to :action => :new , :course_type => params[:course_type], :step => "3"
              }
            else  
              format.html { render "step2_page" }
            end
          end
          
        end
        
        
      when "3"
      @course = Course.find(session[:course_id])
      
      if params[:post_to]
        SchoolAsset.create({:asset_type => "Course", :asset_id => @course.id, :school_id => params[:post_to].to_i})
      end
      
      respond_to do |format|
        
        if @course.update_attributes(params[:course])
          
          #Log.log_activity(@course, 'create', current_user) # só aparece quando é aprovada
          # remover curso da sessao
          session[:course_id] = nil
          if @course.course_type == 'seminar'
             flash[:notice] = 'Aula foi criada com sucesso e está em processo de moderação.'
              format.html { 
                #redirect_to(@course)
                redirect_to waiting_user_courses_path(current_user.id)
              }
          else
             flash[:notice] = 'Aula foi criada com sucesso!'
              format.html { 
                redirect_to(@course)
              }
          end
          
         
        else  
          format.html { render "step3" }
        end
        
      end
      
      
    end


end


def cancel
  if session[:course_id]
   course = Course.find(session[:course_id])
   course.destroy if course
   session[:course_id] = nil
 end

   flash[:notice] = "Criação de aula cancelada."
   redirect_to courses_path
end


  
  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    
   # Log.log_activity(@course, 'update', @course.owner, @school)
    
   @course = Course.find(params[:id])
    
   if @course.course_type == 'interactive'
     @interactive_class = @course.interactive_class
     respond_to do |format|
      if @interactive_class.update_attributes(params[:interactive_class])
        flash[:notice] = 'Curso atualizado com sucesso.'
        format.html { redirect_to(@course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_interactive" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
   elsif @course.course_type == 'page'
     # TODO
   else # seminar
     respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Curso atualizado com sucesso.'
        format.html { redirect_to(@course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_seminar" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
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
       # @acquisition.value =  Course.price_of_acquisition(@course.id) nao mais usado
       @acquisition.value =  Course.price
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
    
    # Só para efeitos de teste. O objeto school vai ser passado na criação das aulas quando estiver
    # dentro de uma rede.
    #@school = School.find(:first, :conditions => ["owner = ?", current_user.id])
    
    Log.log_activity(@course, 'create', @course.owner, @school)
    
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
    @courses = Course.paginate(:conditions => ["owner = ? AND public = 1 AND state LIKE ?", params[:user_id], "waiting"], 
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
