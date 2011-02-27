class LecturesController < BaseController
  layout 'environment'

  before_filter :find_subject_space_course_environment
  after_filter :create_activity, :only => [:create]


  include Viewable # atualiza o view_count
  load_and_authorize_resource :subject
  load_and_authorize_resource :lecture,
    :except => [:new, :create, :cancel, :unpublished_preview],
    :through => :subject

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
       subject = Subject.find(params[:subject_id])
       redirect_to infos_space_subject_path(subject.space, subject)
      end
      format.js { render :js => "alert('Você não possui espaço suficiente.')" }
    end
  end

  # adiciona um objeto embarcado (ex: scribd)
  def embed_content
    @external_object = ExternalObject.new( params[:external_object] )

    respond_to do |format|
      if @external_object.save
        format.js
      else
        format.js do
          render :template => 'lectures/alert', :locals => { :message => 'Houve uma falha no conteúdo'}
        end
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
              render :template => 'lectures/alert', :locals => { :message => success[1]}
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
            render :template => 'lectures/upload_video'
          end
        end
      else
        format.js do
          responds_to_parent do
            render :template => 'lectures/alert', :locals => { :message => "Houve uma falha ao enviar o arquivo." }
          end
        end
      end
    end
  end

  def download_attachment
    @attachment = LectureResource.find(params[:res_id])
    send_file @attachment.attachment.path, :type=> @attachment.attachment.content_type
  end

  def rate
    @lecture.rate(params[:stars], current_user, params[:dimension])
    #TODO Esta linha abaixo é usada pra quê?
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}lecture-#{@lecture.id}"

    respond_to do |format|
      format.js
    end

  end

  def sort_lesson
    params['topic_list'].each_with_index do |id, index|
      Lesson.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end

  def index
    authorize! :read, @subject
    @subject_users = @subject.members.all(:limit => 9) # sidebar
    @lectures = @subject.lectures.paginate(:page => params[:page],
                                          :order => 'position ASC',
                                          :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html { render :template => 'lectures/new/index',
        :layout => 'new/application'}
      format.js { render :template => 'lectures/new/index' }
    end
    #redirect_to space_subject_path(@space, @subject)
  end

  # GET /lectures/1
  # GET /lectures/1.xml
  def show
    update_view_count(@lecture)

    if @lecture.removed
      redirect_to removed_page_path and return
    end

    @subject_users = @subject.members
    # anotações
    @annotation = @lecture.annotations.by_user(current_user)
    @annotation = Annotation.new if @annotation.empty?

    #relacionados
    @related_lectures = Lecture.related_to(@lecture).all(:limit => 3,
                                        :order => 'rating_average DESC')

    @status = Status.new
    @statuses = @lecture.statuses.paginate(:page => params[:page],
                                  :order => 'created_at DESC',
                                  :per_page => AppConfig.items_per_page)
    
    if current_user.get_association_with(@lecture.subject)
      asset_report = @lecture.asset_reports.of_user(current_user).first
      @student_grade = asset_report.student_profile.grade.to_i
      @done = asset_report.done
    end

    respond_to do |format|
      if @lecture.lectureable_type == 'Page'
        format.html do
          render :template => 'lectures/new/show_page', :layout => 'new/application'
        end
      elsif @lecture.lectureable_type == 'Seminar'
        format.html do
          render :template => 'lectures/new/show_seminar',
            :layout => 'new/application'
        end
      elsif @lecture.lectureable_type == 'Document'
        format.html do
          render :template => 'lectures/new/show_document',
            :layout => 'new/application'
        end
      elsif @lecture.lectureable_type == 'InteractiveClass'
        @lessons = Lesson.find_by_interactive_class_id(@lecture.lectureable_id).
                            all(:order => 'position ASC') # TODO 2 consultas?
      end

      format.html
      format.xml  { render :xml => @lecture }
    end

  end

  # GET /lectures/new
  # GET /lectures/new.xml
  def new
    @lecture = Lecture.new
    case params[:type].to_s
    when 'Page'
      @page = Page.new
    when 'Seminar'
      @seminar = Seminar.new
    when 'Document'
      @document = Document.new
    end

    respond_to do |format|
      format.js do
        render :template => 'lectures/new/new'
      end
    end
  end

  # GET /lectures/1/edit
  def edit
    respond_to do |format|
      if @subject.published?
        flash[:notice] = 'O módulo deve ser despublicado para que seja possível a editação das aulas.'
        format.html { redirect_to space_subject_lecture_path(@space, @subject, @lecture) }
      else
        format.js do
          render :update do |page|
            @page = @lecture.lectureable
            page.insert_html :before, 'lectures_types',
              "<fieldset id=\"edit-#{@lecture.id}-item\">
                <legend class=\"label\">Editar recurso</legend>
              </fieldset>"
            page.insert_html :bottom, "edit-#{@lecture.id}-item",
              :partial => 'lectures/new/form_edit_page'
          end
        end
      end

      format.xml  { render :xml => @lecture }
    end
  end

  # POST /lectures
  # POST /lectures.xml
  def create
    if params[:lecture_id] # Existent
      @lecture = Lecture.find(params[:lecture_id])
      @lecture = @lecture.clone_for_subject!(params[:subject_id])
    else
      @lecture = Lecture.new
      @lecture.name = params[:name]
      @lecture.owner = current_user
      @lecture.subject = Subject.find(params[:subject_id])
    end
    quota_files = @space.course.quota.files
    quota_multimedia = @space.course.quota.multimedia
    plan_files_limit = @space.course.plan.file_storage_limit
    plan_multimedia_limit = @space.course.plan.video_storage_limit
    error = false
    if @lecture.name
      if params[:page]
        @page = Page.create(params[:page])
        @lecture.lectureable = @page
      elsif params[:seminar]
        @seminar = Seminar.new(params[:seminar])
        @seminar.lecture = @lecture
        authorize! :upload_multimedia, @seminar
        @seminar.save
      elsif params[:document]
        @document = Document.new(params[:document])
        @document.lecture = @lecture
        authorize! :upload_document, @document
        @document.save
      end
    end

    respond_to do |format|
      if @lecture.save
        @space.course.quota.refresh
        @lecture.published = 1
        @lecture.save
        format.js do
          render :template => 'lectures/new/create'
        end
      else

        format.js { render :template => 'lectures/new/create_error'}
      end
    end
  end

  def unpublished_preview
    @lecture = Lecture.find(session[:lecture_id])
    @lessons = Lesson.find_by_interactive_class_id(@lecture.lectureable_id).
                        all(:order => 'position ASC')
    respond_to do |format|
      format.html {render 'unpublished_preview_interactive'}
    end
  end

  def cancel
    if session[:lecture_id]
      lecture = Lecture.find(session[:lecture_id])
      if lecture
        authorize! :manage, lecture
        # Se não tiver nada na sessão vai parecer que
        # o usuário teve acesso, mas na realidade nada foi destruído.
        lecture.destroy
      end
      session[:lecture_id] = nil
    end

    flash[:notice] = "Criação de aula cancelada."
    @subject = Subject.find(params[:subject_id])
    redirect_to lazy_space_subject_path(@space, @subject)
  end

  # PUT /lectures/1
  # PUT /lectures/1.xml
  def update
    @lecture = Lecture.find(params[:lecture_id])
    @lecture.name = params[:name]

   if params[:page]
     @page = @lecture.lectureable
      valid = @page.update_attributes(params[:page]) && @lecture.save
    elsif params[:seminar]
      @seminar.update_attributes(params[:seminar]) && @lecture.save
    elsif params[:document]
      @document.update_attributes(params[:document]) && @lecture.save
    end
    @lecture.subject.space.course.quota.refresh
    respond_to do |format|
      if valid
        format.js do
          render :template => 'lectures/new/update'
        end
      else
        format.js { render :template => 'lectures/new/create_error'}
      end
    end

  end

  # DELETE /lectures/1
  # DELETE /lectures/1.xml
  def destroy
    @lecture.destroy
    @lecture.subject.space.course.quota.refresh
    respond_to do |format|
      format.html {
        flash[:notice] = "A aula foi removida."
        redirect_to space_subject_path(@space, @subject)
      }
      format.js do
        render :update do |page|
          page.remove "#{@lecture.id}-item"
        end
      end
      format.xml  { head :ok }
    end
  end

  # lista aulas não publicados (em edição)
  # Não precisa de permissão, pois utiliza o current_user.
  def unpublished
    @lectures = current_user.lectures.unpublished.
                  paginate(:include => :owner,
                           :page => params[:page],
                           :order => 'updated_at DESC',
                           :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.js
    end
  end

  # Marca a aula como done para um dado usuário
  def done
    if params[:done] == '0'
      @done = 0
    elsif params[:done] == '1'
      @done = 1
    end
    @lecture.mark_as_done_for!(current_user, @done)

    student_profile = current_user.student_profiles.of_subject(@subject).last
    @student_grade = student_profile.update_grade!.to_i

   respond_to do |format|
     format.js { render :template => 'lectures/new/done' }
     format.html { redirect_to space_subject_lecture_path(@subject.space,
                                                          @subject,
                                                          @lecture) }
   end
  end

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |id, password|
      id == 'zencoder' && password == 'sociallearning'
    end
  end

  def find_subject_space_course_environment
    if @lecture
      @subject = @lecture.subject
    else
      @subject = Subject.find(params[:subject_id])
    end

    @space = @subject.space
    @course = @space.course
    @environment = @course.environment
  end
end
