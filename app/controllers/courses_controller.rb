class CoursesController < BaseController

  include Viewable # atualiza o view_count
  uses_tiny_mce(:options => AppConfig.advanced_mce_options, :only => [:new, :edit, :update, :create])

  before_filter :login_required, :except => [:index]
  before_filter :verify_access, :only => [:show]
  after_filter :create_activity, :only => [:create]

  def verify_access
    @course = Course.find(params[:id])
    unless current_user.has_access_to @course
      flash[:notice] = "Você não tem acesso a esta aula"
      #redirect_back_or_default courses_path
      redirect_to courses_path
    end
  end

  # adiciona um objeto embarcado (ex: scribd)
  def embed_content
    @external_object = ExternalObject.new( params[:external_object] )

    respond_to do |format|
      if @external_object.save
        format.js do
          render :update do |page|
            page.replace_html('external_object_' + params[:child_index], :partial => 'form_lesson_object_loaded', :locals => {:ch_index => params[:child_index]})
            page << "jQuery('#spinner').hide();"
          end
        end
      else
        format.js {
          render :update do |page|
            page << "alert('houve uma falha no conteúdo');"
          end
        }
      end
    end
  end

  # faz upload de video em ajax em uma aula interativa
  def upload_video
    @seminar = Seminar.new( params[:seminar] )

    if @seminar.external_resource_type.eql?('redu') # importar video do Redu atraves de url
      success = @seminar.import_redu_seminar(@seminar.external_resource)

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
    end

    respond_to do |format|
      if @seminar.save
        @seminar.convert! if @seminar.video? and not @seminar.state == 'converted'

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
    send_file @attachment.attachment.path, :type=> @attachment.attachment.content_type, :x_sendfile=>true
  end

  def rate
    @course = Course.find(params[:id])
    @course.rate(params[:stars], current_user, params[:dimension])
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}course-#{@course.id}"

    render :update do |page|
      page.replace_html  @course.wrapper_dom_id(params), ratings_for(@course, params.merge(:wrap => false))
    end
  end

  def sort_lesson
    params['topic_list'].each_with_index do |id, index|
      Lesson.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end

  # GET /courses
  # GET /courses.xml
  def index
    cond = Caboose::EZ::Condition.new
    cond.append ["simple_category_id = ?", params[:category]] if params[:category]
    cond.append ["courseable_type = ?", params[:type]] if params[:type]
    cond.append ["is_clone = false"]

    paginating_params = {
      :conditions => cond.to_sql,
      :page => params[:page],
      :order => (params[:sort]) ? params[:sort] + ' DESC' : 'created_at DESC',
      :per_page => AppConfig.items_per_page
    }

    if params[:user_id] # aulas do usuario
      @user = User.find_by_login(params[:user_id])
      @user = User.find(params[:user_id]) unless @user
      @courses = @user.courses.paginate(paginating_params)
      render((@user == current_user) ? "user_courses_private" :  "user_courses_public")
      return

    elsif params[:school_id] # aulas da escola
      @school = School.find(params[:school_id])
      if params[:search] # search aulas da escola
        @courses = @school.courses.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
      else
        @courses = @school.courses.paginate(paginating_params)
      end
    else # index (Course)
      if params[:search] # search
        @courses = Course.published.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
      else
        @courses = Course.published.paginate(paginating_params)
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }

      format.js  do
        if params[:school_content]
          render :update do |page|
            page.replace_html  'content_list', :partial => 'course_list'
            page << "$('#spinner').hide()"
          end
        elsif params[:tab]
          render :update do |page|
            page.replace_html  'tabs-2-content', :partial => 'courses_school'
          end
        else
          render :index
        end
      end
    end
  end

  # GET /courses/1
  # GET /courses/1.xml
  def show
    @school = School.find(params[:school_id]) if params[:school_id]
    update_view_count(@course)

    if @course.removed
      redirect_to removed_page_path and return
    end

    # anotações
    @annotation = @course.has_annotations_by(current_user)
    @annotation = Annotation.new unless @annotation
    #relacionados
    related_name = @course.name
    @related_courses = Course.find(:all,:conditions => ["name LIKE ? AND id NOT LIKE ?","%#{related_name}%", @course.id] , :limit => 3, :order => 'rating_average DESC')
    @status = Status.new
    
    current_user.student_profiles.find_by_subject_id(@course.course_subject.subject.id).to_count(@course) unless params[:to_count].nil?
   
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

      unless @course #curso não foi encontrado ou nao está mais na sessão
        redirect_to new_course_path :school_id => params[:school_id]
      end

      if @course.courseable_type == 'Seminar'
        @seminar = Seminar.new

        render "step2_seminar" and return
      elsif @course.courseable_type == 'InteractiveClass'
        @interactive_class = InteractiveClass.new
        render "step2_interactive" and return
      elsif @course.courseable_type == 'Page'
        @page = Page.new
        render "step2_page" and return
      end
    when "3"
      @course = Course.find(session[:course_id])
      @schools = current_user.schools

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
    #TODO diminuir a lógica desse método, está muito GRANDE
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
        @seminar = Seminar.new(params[:seminar])
        @course.courseable = @seminar

        # importar video do Redu atraves de url
        @success = @seminar.import_redu_seminar(@seminar.external_resource) if @seminar.external_resource_type.eql?('redu')
        respond_to do |format|

          if @success && !@success[0]  # importação falhou
            flash[:error] = @success[1]
            format.html { render("step2_seminar")  }
          else
            if @course.save

              format.html do
                redirect_to :action => :new , :course_type => params[:courseable_type], :step => "3", :school_id => params[:school_id]
              end

              format.js do
                render :update do |page|
                  page << "window.location.replace('#{ url_for :action => :new , :course_type => params[:courseable_type], :step => "3", :school_id => params[:school_id] }')"
                  page << "$('.errorMessageField').remove()"
                end
              end

            else
              format.html { render "step2_seminar" }
              format.js do
                render :update do |page|
                  page << "$('#uploadify_submit').before('<span class=\"errorMessageField\">Formato inválido</span>')"
                end
              end

            end
          end
        end

      elsif @course.courseable_type == 'InteractiveClass'
      #Course.find(session[:course_id]).courseable
        @course.courseable = InteractiveClass.new(params[:interactive_class])

        respond_to do |format|

          if @course.save

            format.html do
              redirect_to :action => :new , :course_type => params[:courseable_type], :step => "3", :school_id => params[:school_id]
            end
            format.js do
              render :update do |page|
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
          @course.courseable.convert!
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

  # lista cursos não publicados (em edição)
  def unpublished
    @courses = Course.paginate(:conditions => ["owner = ? AND published = 0", current_user.id],
                               :include => :owner,
                               :page => params[:page],
                               :order => 'updated_at DESC',
                               :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.js do
        render :update do |page|
          page << "$('#tabs-2-loading').hide()"
          page.replace_html 'tabs-2-content', :partial => "course_list"
        end
      end
    end
  end

  # cursos publicados no redu esperando a moderação dos admins do redu
  def waiting
    @user = current_user
    @courses = Course.paginate(:conditions => ["owner = ? AND published = 1 AND state LIKE 'waiting'", current_user.id],
                               :include => :owner,
                               :page => params[:page],
                               :order => 'updated_at DESC',
                               :per_page => AppConfig.items_per_page)
    @tab_selected = 'waiting'

    respond_to do |format|
      format.html do
        render "user_courses_private"
      end
      format.js do
        render :update do |page|
          page << "$('#tabs-3-loading').hide()"
          page.replace_html 'tabs-3-content', :partial => "course_list"
        end
      end
    end
  end

  def notify

  end

  protected

    def authenticate
      authenticate_or_request_with_http_basic do |id, password|
        id == 'zencoder' && password == 'sociallearning'
      end
    end
end
