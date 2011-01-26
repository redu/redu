class LecturesController < BaseController
  layout 'environment'

  before_filter :find_subject_space_course_environment
  after_filter :create_activity, :only => [:create]

  include Viewable # atualiza o view_count
  load_and_authorize_resource :lecture,
    :except => [:new, :create, :cancel, :unpublished_preview]

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
    redirect_to space_subject_path(@space, @subject)
  end
  # GET /lectures/1
  # GET /lectures/1.xml
  def show
    update_view_count(@lecture)

    if @lecture.removed
      redirect_to removed_page_path and return
    end

    # anotações
    @annotation = @lecture.annotations.by_user(current_user)
    @annotation = Annotation.new unless @annotation

    #relacionados
    @related_lectures = Lecture.related_to(@lecture).all(:limit => 3,
                                        :order => 'rating_average DESC')

    @status = Status.new

    respond_to do |format|
      if @lecture.lectureable_type == 'Page'
      elsif @lecture.lectureable_type == 'InteractiveClass'
        @lessons = Lesson.find_by_interactive_class_id(@lecture.lectureable_id).
                            all(:order => 'position ASC') # TODO 2 consultas?
      elsif @lecture.lectureable_type == 'Seminar'
        #@seminar = @lecture.lectureable
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
      format.js
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
            page.insert_html :after, "#{@lecture.id}-item", :partial => 'form_edit_page'
            page.remove "#{@lecture.id}-item"
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

    if params[:page]
      @page = Page.create(params[:page]) if @lecture.name
      @lecture.lectureable = @page
    elsif params[:seminar]
      # Verificação para que o Seminar não seja criado em vão.
      @seminar = Seminar.create(params[:seminar]) if @lecture.name
      @lecture.lectureable = @seminar
    elsif params[:document]
      @document = Document.create(params[:document]) if @lecture.name
      @lecture.lectureable = @document
    end

    respond_to do |format|
      if @lecture.save
        format.js
      else
        format.js { render :template => 'lectures/create_error'}
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

    respond_to do |format|
      format.html { redirect_to(lectures_url) }
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
