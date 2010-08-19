class CoursesController < BaseController
 layout 'new_application'
 include Viewable # serve pra atualizar o view_count
    
  before_filter :login_required, :except => [:index]
  #before_filter :check_if_removed, :except => [:index]
   # before_filter :require_no_user, :only => [:new, :create]
 # before_filter :require_user, :only => :destroy
  
  uses_tiny_mce(:options => AppConfig.advanced_mce_options, :only => [:new, :edit, :update])
  
#  def check_if_removed
#    puts params[:id]
#  end

  
  # adiciona um objeto embarcado (ex: scribd)
  def embed_content
    @external_object = ExternalObject.new( params[:external_object] )
    
    respond_to do |format|
      if @external_object.save
        format.js do
            render :update do |page|
              #puts 'external_object_' + params[:child_index]
              page.replace_html('external_object_' + params[:child_index], :partial => 'form_lesson_object_loaded', :locals => {:ch_index => params[:child_index]})
              page << "jQuery('#spinner').hide();"
            end
        end
      else
         format.js do
            render :update do |page|
              page << "alert('houve uma falha no conteúdo');"
            end
        end
      end
    end
    
  end
  
  
  # faz upload de video em ajax em uma aula interativa
  def upload_video
    
    @seminar = Seminar.new( params[:seminar] )
    
    # importar video do Redu atraves de url
    success = @seminar.import_redu_seminar(@seminar.external_resource) if @seminar.external_resource_type.eql?('redu')
    
    unless success and success[0] # importação falhou
      respond_to do |format|
        format.js do
          responds_to_parent do
            render :update do |page|
              page << "alert('"+ success[1] +"');"
            end 
          end 
        end
      end
      return
    end
    
    respond_to do |format|
      if @seminar.save
        format.js do
          responds_to_parent do
            render :update do |page|
              page.replace_html('video_upload_' + params[:child_index], :partial => 'form_lesson_seminar_uploaded', :locals => {:seminar => @seminar, :ch_index => params[:child_index]})
              page << "jQuery('#spinner').hide();"
            end
          end
        end
      else
         format.js do
          responds_to_parent do
            render :update do |page|
              page << "alert('houve uma falha ao enviar o arquivo');"
            end
          end
        end
      end
    end
  end
  
  

  
  
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
     # page << "$('##{id}').effect('highlight', {}, 2000);" #TODO precisa do plugin de effects do jquery
      #page.visual_effect :highlight, id
    end
  end
  
  def sort_lesson 
    
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
    
    if params[:user_id] # aulas do usuario
      @user = User.find_by_login(params[:user_id]) 
      @user = User.find(params[:user_id]) unless @user
      
      @courses = @user.courses.paginate :page => params[:page], :per_page => AppConfig.items_per_page
      
      respond_to do |format|
        format.html { render :action => "user_courses"} 
        format.xml  { render :xml => @user.courses }
      end
    elsif params[:school_id] # aulas da escola
      @school = School.find(params[:school_id])
      @courses = @school.courses.paginate( 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
      
      respond_to do |format|
        format.html { 
           #redirect_to(school_path(@school, :anchor => "tabs-2")) #mostra aulas no tab
           render 'index_school'
        }
        format.js  {
          render :update do |page|
            page.replace_html  'tabs-2-content', :partial => 'courses_school'
          end
        }
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
    update_view_count(@course)
    
    if @course.removed
      redirect_to removed_page_path and return
    end
    

      #comentários
      @comments  = @course.comments.find(:all, :limit => 10, :order => 'created_at DESC')
      
      # anotações
      @annotation = @course.has_annotations_by(current_user) 
      @annotation = Annotation.new unless @annotation
      
      #relacionados
      related_name = @course.name
      @related_courses = Course.find(:all,:conditions => ["name LIKE ? AND id NOT LIKE ?","%#{related_name}%", @course.id] , :limit => 3, :order => 'created_at DESC')
      
     #@course.update_attribute(:view_count, @course.view_count + 1) #TODO em Viewable
      
     # Log.log_activity(@course, 'show', current_user, @school)#TODO se usuario nao comprou não logar atividade

      respond_to do |format|
        if @course.courseable_type == 'Page'
        elsif @course.courseable_type == 'InteractiveClass'
          @lessons = Lesson.all(:conditions => ['interactive_class_id = ?',@course.courseable_id ], :order => 'position ASC') # TODO 2 consultas?
        elsif @course.courseable_type == 'Seminar'
          #@seminar = @course.courseable
        end
        
        format.html
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
    if params[:school_id]
     @school = School.find(params[:school_id]) 
    end
    
    case params[:step]
      when "2"
        
         @course = Course.find(session[:course_id])
        
        if @course.courseable_type == 'Seminar'
          @seminar = Seminar.new
          #3.times { @seminar.resources.build }
        
        
#          3.times { @course.resources.build }
#        
#          @course.enable_validation_group :step2_seminar
#          @edit = false
          render "step2_seminar" and return
        
        elsif @course.courseable_type == 'InteractiveClass'
          @interactive_class = InteractiveClass.new
          
           #3.times { @interactive_class.resources.build }
          
          render "step2_interactive" and return
        
        elsif @course.courseable_type == 'Page'
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
        if @course.courseable_type == 'Page'
          format.html {render 'edit_page'}
        elsif @course.courseable_type == 'InteractiveClass'
          @interactive_class = @course.courseable
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
    #TODO diminuir a lógica desse método
    case params[:step]
      when "1"
          @course = Course.new(params[:course])
          @course.owner = current_user
          @course.enable_validation_group :step1
          
          respond_to do |format|
            if @course.save
              
              session[:course_id] = @course.id
              
              format.html { 
                redirect_to :action => :new, :step => "2", :school_id => params[:school_id]
              }
            else  
              @school = School.find(params[:school_id]) if params[:school_id]
              format.html { render "step1" }
            end
          end
          
      
    when "2"
        @course = Course.find(session[:course_id])
        @course.enable_validation_group :step2
        
        @res = []
        if params[:seminar] and  params[:seminar][:attachment]
          params[:seminar][:attachment].each do |a|
            @res = CourseResource.create(:attachment => a, :attachable => @course)
          end
        end
        
        if @course.courseable_type == 'Seminar'
          
          
          
          @course.courseable = Seminar.new(params[:seminar])
          
           respond_to do |format|
            
            if @course.save
              
              format.html { 
                 redirect_to :action => :new , :course_type => params[:courseable_type], :step => "3", :school_id => params[:school_id]
              }
                
            else  
              format.html { render "step2_seminar" }
              
            end
          end

        elsif @course.courseable_type == 'InteractiveClass'
          
          @course.courseable = InteractiveClass.new(params[:interactive_class])
           
           respond_to do |format|
            
            if @course.save
              
              format.html do 
                 redirect_to :action => :new , :course_type => params[:courseable_type], :step => "3", :school_id => params[:school_id]
              end
              format.js do
                  render :update do |page| 
                    #page << "alert('salvo!')"
                    #page << "jQuery('#save_btn').val('Salvo em ')"
                    page << "jQuery('#save_info').html('Salvo em #{Time.now.utc}')"
                  end
                end
            else  
              format.html do
                render "step2_interactive" 
              end
              format.js do
                  render :update do |page| 
                    page << "alert('Erro ao salvar. Tente novamente em alguns instantes.')"
                  end
                end
            end
          end
          
        elsif @course.courseable_type == 'Page'
          
          @course.courseable =  Page.new(params[:page])
          
           respond_to do |format|
            
            if @course.save
              
              format.html { 
                 redirect_to :action => :new , :courseable_type => params[:courseable_type], :step => "3", :school_id => params[:school_id]
              }
            else  
              format.html { render "step2_page" }
            end
          end
          
        end
        
        
      when "3"
      @course = Course.find(session[:course_id])
      
      
      @submited_to_school = false
      if params[:post_to]
        SchoolAsset.create({:asset_type => "Course", :asset_id => @course.id, :school_id => params[:post_to].to_i})
        @school = School.find(params[:post_to])
      end
      
      @course.published = true # se o usuário completou os 3 passos então o curso está publicado
      
      # Enfileirando video para conversão
      if @course.courseable_type.eql?('Seminar')
        if @course.courseable.need_transcoding?
          Delayed::Job.enqueue VideoTranscodingJob.new(@course.courseable)
        else
          @course.courseable.ready!
        end
      end
            
      if @school
        if @school.submission_type = 1 # todos podem postar
          params[:course][:state] = "approved"
        elsif @school.submission_type = 2 # todos com moderação
           params[:course][:state] = "waiting"
        elsif @school.submission_type = 3 # apenas professores
          if current_user.can_post @school
           params[:course][:state] = "rejected"
          else
           params[:course][:state] = "approved"
          end
        else
          params[:course][:state] = "approved"
        end
      else #publico
        params[:course][:state] = "waiting"
      end

      respond_to do |format|
        
        if @course.update_attributes(params[:course])
          #Log.log_activity(@course, 'create', current_user) # só aparece quando é aprovada
          # remover curso da sessao
          session[:course_id] = nil
          if @course.courseable_type == 'Seminar' or  @course.courseable_type == 'InteractiveClass'
             
              format.html do 
                if @school
                    if @school.submission_type = 1 # todos podem postar
                       #mostra aulas da escola
                       flash[:notice] = 'Aula foi criada com sucesso e está disponível na rede.'
                      redirect_to school_courses_path(:school_id => params[:post_to].to_i, :id => @course.id)
                    
                  elsif @school.submission_type = 2 # todos com moderação
                    flash[:notice] = 'Aula foi criada com sucesso e está em processo de moderação.'
                       redirect_to waiting_user_courses_path(current_user.id)
                    elsif @school.submission_type = 3 # apenas professores
                      flash[:notice] = 'Aula não pode ser publicada nessa escola pois apenas professores podem postar.'
                       redirect_to @course
                  else
                     redirect_to school_course_path(:school_id => params[:post_to].to_i, :id => @course.id)
                  end
                  
                  
                else
                  flash[:notice] = 'Aula foi criada com sucesso e está em processo de moderação.'
                  redirect_to waiting_user_courses_path(current_user.id)
                end
              end
          else
             flash[:notice] = 'Aula foi criada com sucesso!'
              format.html do 
                redirect_to(@course)
              end
          end
          
         
        else  
          format.html { render "step3" }
        end
        
      end
    end
end

def unpublished_preview
  @course = Course.find(session[:course_id])
  
  
  @lessons = Lesson.all(:conditions => ['interactive_class_id = ?',@course.courseable_id ], :order => 'position ASC')
  respond_to do |format|         
    format.html {render 'unpublished_preview_interactive'}
    
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
    
   if @course.courseable_type == 'InteractiveClass'
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
  elsif @course.courseable_type == 'Page'
    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Curso atualizado com sucesso.'
        format.html { redirect_to(@course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_page" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
    end
    end
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
  
  
  
  
  
  # lista cursos publicados por autor (sejam em redes ou público no redu)
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
  
  # lista cursos não publicados (em edição)
  def unpublished
    @courses = Course.paginate(:conditions => ["owner = ? AND published = 0", current_user.id], 
      :include => :owner, 
      :page => params[:page], 
      :order => 'updated_at DESC', 
      :per_page => AppConfig.items_per_page)
    
    respond_to do |format|
      format.html #{ render :action => "my" }
      format.xml  { render :xml => @resources }
    end
  end
  
  # cursos publicados no redu esperando a moderação dos admins do redu
  def waiting
    @courses = Course.paginate(:conditions => ["owner = ? AND public = 1 AND published = 1 AND state LIKE 'waiting'", params[:user_id]], 
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
