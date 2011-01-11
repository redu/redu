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
    @annotation = @lecture.has_annotations_by(current_user)
    @annotation = Annotation.new unless @annotation

    #relacionados
    related_name = @lecture.name
    @related_lectures = Lecture.find(:all,:conditions => ["name LIKE ? AND id NOT LIKE ?","%#{related_name}%", @lecture.id] , :limit => 3, :order => 'rating_average DESC')

    @status = Status.new

    respond_to do |format|
      if @lecture.lectureable_type == 'Page'
      elsif @lecture.lectureable_type == 'InteractiveClass'
        @lessons = Lesson.all(:conditions => ['interactive_class_id = ?',@lecture.lectureable_id ], :order => 'position ASC') # TODO 2 consultas?
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
  end

  # GET /lectures/1/edit
  def edit
    respond_to do |format|
      if @subject.published?
        flash[:notice] = 'O módulo deve ser despublicado para que seja possível a editação das aulas.'
        format.html { redirect_to space_subject_lecture_path(@space, @subject, @lecture) }
      else
        if @lecture.lectureable_type == 'Page'
          @page = @lecture.lectureable
          format.html {render 'edit_page'}
        elsif @lecture.lectureable_type == 'InteractiveClass'
          @interactive_class = @lecture.lectureable
          format.html {render 'edit_interactive'}
        elsif @lecture.lectureable_type == 'Seminar'
          format.html {render 'edit_seminar'}
        else
          format.html {render 'edit_document'}
        end
      end

      format.xml  { render :xml => @lecture }
    end
  end

  # POST /lectures
  # POST /lectures.xml
  def create
  end

  def unpublished_preview
    @lecture = Lecture.find(session[:lecture_id])
    @lessons = Lesson.all(:conditions => ['interactive_class_id = ?',@lecture.lectureable_id ], :order => 'position ASC')
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
    if @lecture.lectureable_type == 'InteractiveClass'
      @interactive_class = @lecture.interactive_class
      respond_to do |format|
        if @interactive_class.update_attributes(params[:interactive_class])
          flash[:notice] = 'Curso atualizado com sucesso.'
          format.html { redirect_to(@lecture) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit_interactive" }
          format.xml  { render :xml => @lecture.errors, :status => :unprocessable_entity }
        end
      end
    elsif @lecture.lectureable_type == 'Page'
      respond_to do |format|
        @page = @lecture.lectureable
        if params[:lecture]
          if @lecture.update_attributes(params[:lecture])
            sucesso = true
          else
            sucesso = false
          end
        elsif params[:page]
          if @page.update_attribute 'body', params[:page][:body] 
            sucesso = true
          else
            sucesso = false
          end
        else
          sucesso = false
        end

        if sucesso
          flash[:notice] = 'Artigo atualizado com sucesso.'
          format.html { redirect_to lazy_space_subject_path(@space,@subject) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit_page" }
          format.xml  { render :xml => @lecture.errors, :status => :unprocessable_entity }
        end

      end
     elsif @lecture.lectureable_type == 'Seminar'
      respond_to do |format|
        if @lecture.update_attributes(params[:lecture])
          flash[:notice] = 'Vídeo-aula atualizada com sucesso.'
          format.html { redirect_to lazy_space_subject_path(@space,@subject) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit_seminar" }
          format.xml  { render :xml => @lecture.errors, :status => :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @lecture.update_attributes(params[:lecture])
          flash[:notice] = 'Apresentação atualizada com sucesso.'
          format.html { redirect_to lazy_space_subject_path(@space,@subject) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit_document" }
          format.xml  { render :xml => @lecture.errors, :status => :unprocessable_entity }
        end
      end
    end

  end

  # DELETE /lectures/1
  # DELETE /lectures/1.xml
  def destroy
    @lecture.destroy
    flash[:notice] = 'A aula foi removida'

    respond_to do |format|
      format.html { redirect_to(lectures_url) }
      format.xml  { head :ok }
    end
  end

  # lista aulas não publicados (em edição)
  # Não precisa de permissão, pois utiliza o current_user.
  def unpublished
    @lectures = Lecture.paginate(:conditions => ["owner = ? AND published = 0", current_user.id],
                               :include => :owner,
                               :page => params[:page],
                               :order => 'updated_at DESC',
                               :per_page => AppConfig.items_per_page)

    respond_to do |format|
      format.js
    end
  end

  # cursos publicados no redu esperando a moderação dos admins do redu
  # Não precisa de permissão, pois utiliza o current_user.
  def waiting
    @user = current_user
    @lectures = Lecture.paginate(:conditions => ["owner = ? AND published = 1 AND state LIKE 'waiting'", current_user.id],
                               :include => :owner,
                               :page => params[:page],
                               :order => 'updated_at DESC',
                               :per_page => AppConfig.items_per_page)
    @tab_selected = 'waiting'

    respond_to do |format|
      format.html do
        render "user_lectures_private"
      end
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
