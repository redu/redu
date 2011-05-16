class LecturesController < BaseController
  require 'viewable'
  respond_to :html, :js

  before_filter :find_subject_space_course_environment
  after_filter :create_activity, :only => [:create]


  include Viewable # atualiza o view_count
  load_and_authorize_resource :subject
  load_and_authorize_resource :lecture,
    :except => [:new, :create, :cancel],
    :through => :subject

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
       space = Space.find(params[:space_id])
       redirect_to preview_environment_course_path(space.course.environment,
                                                   space.course)
      end
      format.js { render :js => "alert('Você não possui espaço suficiente.')" }
    end
  end

  def rate
    @lecture.rate(params[:stars], current_user, params[:dimension])
    #TODO Esta linha abaixo é usada pra quê?
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}lecture-#{@lecture.id}"

    respond_to do |format|
      format.js
    end

  end

  def index
    authorize! :read, @subject
    @subject_users = @subject.members.all(:limit => 9) # sidebar
    @lectures = @subject.lectures.paginate(:page => params[:page],
                                          :order => 'position ASC',
                                          :per_page => Redu::Application.config.items_per_page)
    respond_to do |format|
      format.html
      format.js do
        render_endless 'lectures/item', @lectures, '#subject-resources > ol'
      end
    end
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
    @statuses = @lecture.statuses.not_response.
      paginate(:page => params[:page],:order => 'created_at DESC',
               :per_page => Redu::Application.config.items_per_page)

    if current_user.get_association_with(@lecture.subject)
      asset_report = @lecture.asset_reports.of_user(current_user).first
      @student_grade = asset_report.student_profile.grade.to_i
      @done = asset_report.done
    end

    respond_to do |format|
      if @lecture.lectureable_type == 'Page'
        format.html do
          render :show_page
        end
      elsif @lecture.lectureable_type == 'Seminar'
        format.html do
          render :show_seminar
        end
      elsif @lecture.lectureable_type == 'Document'
        format.html do
          render :show_document
        end
      end

      format.html
      format.xml  { render :xml => @lecture }
    end

  end

  # GET /lectures/new
  # GET /lectures/new.xml
  def new
    @lecture = Lecture.new
    @type = params.fetch(:type, 'Page')

    case @type
    when 'Page'
      @page = Page.new
    when 'Seminar'
      @seminar = Seminar.new
    when 'Document'
      @document = Document.new
    end

    respond_with(@space, @subject, @lecture)
  end

  # GET /lectures/1/edit
  def edit
    @page = @lecture.lectureable
    respond_with(@space, @subject, @lecture)
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

    if @lecture.name
      if params[:page]
        @page = Page.create(params[:page])
        @lecture.lectureable = @page
      elsif params[:seminar]
        @seminar = Seminar.new(params[:seminar])
        @seminar.lecture = @lecture
        authorize! :upload_multimedia, @seminar
        @seminar.save_with_validation_group
      elsif params[:document]
        @document = Document.new(params[:document])
        @document.lecture = @lecture
        authorize! :upload_document, @document
        @document.save
      end
    end

    respond_to do |format|
      if @lecture.save
        # verificação e conversão de tipos necessários
        if @lecture.lectureable_type == 'Seminar'
          @lecture.lectureable.convert! if @lecture.lectureable.need_transcoding?
        elsif @lecture.lectureable_type == 'Document'
          @lecture.lectureable.upload_to_scribd
        end

        @space.course.quota.refresh
        @lecture.published = 1
        @lecture.save
        format.js
      else
        format.js { render :create_error }
      end
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
        format.js
      else
        format.js { render :template => 'lectures/create_error'}
      end
    end

  end

  # DELETE /lectures/1
  # DELETE /lectures/1.xml
  def destroy
    @lecture.destroy
    @lecture.subject.space.course.quota.refresh
    @lecture.refresh_students_profiles

   respond_with(@space, @subject, @lecture) do |format|
      format.html do
        flash[:notice] = "A aula foi removida."
        redirect_to space_subject_path(@space, @subject)
      end
    end
  end

  # lista aulas não publicados (em edição)
  # Não precisa de permissão, pois utiliza o current_user.
  def unpublished
    @lectures = current_user.lectures.unpublished.
                  paginate(:include => :owner,
                           :page => params[:page],
                           :order => 'updated_at DESC',
                           :per_page => Redu::Application.config.items_per_page)

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
     format.js
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
