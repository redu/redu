class LecturesController < BaseController

  include Viewable # atualiza o view_count
  uses_tiny_mce(:options => AppConfig.advanced_mce_options, :only => [:new, :edit, :update, :create])

  before_filter :login_required, :except => [:index]
  before_filter :verify_access, :only => [:show]
  after_filter :create_activity, :only => [:create]

  def verify_access
    @lecture = Lecture.find(params[:id])
    unless current_user.has_access_to @lecture
      flash[:notice] = "Você não tem acesso a esta aula"
      #redirect_back_or_default lectures_path
      redirect_to lectures_path
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
          render :template => 'courses/alert', :locals => { :message => 'Houve uma falha no conteúdo'}
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
              render :template => 'courses/alert', :locals => { :message => success[1]}
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
            render :template => 'courses/upload_video'
          end
        end
      else
        format.js do
          responds_to_parent do
            render :template => 'courses/alert', :locals => { :message => "Houve uma falha ao enviar o arquivo." }
          end
        end
      end
    end
  end

  def download_attachment
    @attachment = LectureResource.find(params[:res_id])
    send_file @attachment.attachment.path, :type=> @attachment.attachment.content_type, :x_sendfile=>true
  end

  def rate
    @lecture = Lecture.find(params[:id])
    @lecture.rate(params[:stars], current_user, params[:dimension])
    #TODO Esta linha abaixo é usada pra quê?
    id = "ajaxful-rating-#{!params[:dimension].blank? ? "#{params[:dimension]}-" : ''}course-#{@lecture.id}"

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

  # GET /lectures
  # GET /lectures.xml
  def index
    cond = Caboose::EZ::Condition.new
    cond.append ["simple_category_id = ?", params[:category]] if params[:category]
    cond.append ["lectureable_type = ?", params[:type]] if params[:type]
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
      @lectures = @user.lectures.paginate(paginating_params)
      render((@user == current_user) ? "user_lectures_private" :  "user_lectures_public")
      return

    elsif params[:space_id] # aulas da escola
      @space = Space.find(params[:space_id])
      if params[:search] # search aulas da escola
        @lectures = @space.lectures.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
      else
        @lectures = @space.lectures.paginate(paginating_params)
      end
    else # index (Lecture)
      if params[:search] # search
        @lectures = Lecture.published.name_like_all(params[:search].to_s.split).ascend_by_name.paginate(paginating_params)
      else
        @lectures = Lecture.published.paginate(paginating_params)
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lectures }

      format.js  do
        if params[:space_content]
          render :template => 'lecture/lecture_list'
        elsif params[:tab]
          render :template => 'lecture/lecture_space'
        else
          render :index
        end
      end
    end
  end

  # GET /lectures/1
  # GET /lectures/1.xml
  def show
    @space = Space.find(params[:space_id]) if params[:space_id]
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

  def view
    @lecture = Lecture.find(params[:id])
    @comments  = @lecture.comments.find(:all, :limit => 10, :order => 'created_at DESC')

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lecture }
    end
  end

  # GET /lectures/new
  # GET /lectures/new.xml
  def new
    if params[:space_id]
      @space = Space.find(params[:space_id])
    end

    case params[:step]
    when "2"

      @lecture = Lecture.find(session[:lecture_id])

      unless @lecture #curso não foi encontrado ou nao está mais na sessão
        redirect_to new_lecture_path :space_id => params[:space_id]
      end

      if @lecture.lectureable_type == 'Seminar'
        @seminar = Seminar.new

        render "step2_seminar" and return
      elsif @lecture.lectureable_type == 'InteractiveClass'
        @interactive_class = InteractiveClass.new
        render "step2_interactive" and return
      elsif @lecture.lectureable_type == 'Page'
        @page = Page.new
        render "step2_page" and return
      end
    when "3"
      @lecture = Lecture.find(session[:lecture_id])
      @spaces = current_user.spaces

      @lecture.enable_validation_group :step3
      render "step3" and return
    else # 1
      if session[:lecture_id]
        @lecture = Lecture.find(session[:lecture_id])
      else
        @lecture = Lecture.new
      end

      @lecture.enable_validation_group :step1
      render "step1" and return
    end
  end

  # GET /lectures/1/edit
  def edit
    @lecture = Lecture.find(params[:id])

    respond_to do |format|
      if @lecture.lectureable_type == 'Page'
        format.html {render 'edit_page'}
      elsif @lecture.lectureable_type == 'InteractiveClass'
        @interactive_class = @lecture.lectureable
        format.html {render 'edit_interactive'}
      else # TODO colocar type == seminar / estamos considerando que o resto é seminário
        format.html {render 'edit_seminar'}
      end

      format.xml  { render :xml => @lecture }
    end
  end

  # POST /lectures
  # POST /lectures.xml
  def create
    #TODO diminuir a lógica desse método, está muito GRANDE
    case params[:step]
    when "1"
      @lecture = Lecture.new(params[:lecture])
      @lecture.owner = current_user
      @lecture.enable_validation_group :step1

      respond_to do |format|
        if @lecture.save

          session[:lecture_id] = @lecture.id

          format.html {
            redirect_to :action => :new, :step => "2", :space_id => params[:space_id]
          }
        else
          @space = Space.find(params[:space_id]) if params[:space_id]
          format.html { render "step1" }
        end
      end

    when "2"
      @lecture = Lecture.find(session[:lecture_id])
      @lecture.enable_validation_group :step2

      @res = []
      if params[:seminar] and  params[:seminar][:attachment]
        params[:seminar][:attachment].each do |a|
          @res = LectureResource.create(:attachment => a, :attachable => @lecture)
        end
      end

      if @lecture.lectureable_type == 'Seminar'
        @seminar = Seminar.new(params[:seminar])
        @lecture.lectureable = @seminar

        # importar video do Redu atraves de url
        @success = @seminar.import_redu_seminar(@seminar.external_resource) if @seminar.external_resource_type.eql?('redu')
        respond_to do |format|

          if @success && !@success[0]  # importação falhou
            flash[:error] = @success[1]
            format.html { render("step2_seminar")  }
          else
            if @lecture.save

              format.html do
                redirect_to :action => :new , :lecture_type => params[:lectureable_type], :step => "3", :space_id => params[:space_id]
              end

              format.js do
                render :template => 'lecture/create_seminar', :locals => { :course_type => params[:courseable_type], :step => "3", :space_id => params[:space_id] }  
              end

            else
              format.html { render "step2_seminar" }
              format.js do
                render :template => 'courses/create_seminar_error'  
              end

            end
          end
        end

      elsif @lecture.lectureable_type == 'InteractiveClass'
        #Lecture.find(session[:lecture_id]).lectureable
        @lecture.lectureable = InteractiveClass.new(params[:interactive_class])

        respond_to do |format|

          if @lecture.save

            format.html do
              redirect_to :action => :new , :lecture_type => params[:lectureable_type], :step => "3", :space_id => params[:space_id]
            end
            format.js do
              render :template => 'courses/create_interactive'  
            end
          else
            format.html do
              render "step2_interactive"
            end
            format.js do
             render :template => 'courses/create_interactive_error' 
            end
          end
        end

      elsif @lecture.lectureable_type == 'Page'

        @lecture.lectureable =  Page.new(params[:page])

        respond_to do |format|

          if @lecture.save

            format.html {
              redirect_to :action => :new , :lectureable_type => params[:lectureable_type], :step => "3", :space_id => params[:space_id]
            }
          else
            format.html { render "step2_page" }
          end
        end

      end

    when "3"
      @lecture = Lecture.find(session[:lecture_id])
      @submited_to_space = false
      if params[:post_to]
        SpaceAsset.create({:asset_type => "Lecture", :asset_id => @lecture.id, :space_id => params[:post_to].to_i})
        @space = Space.find(params[:post_to])
      end

      @lecture.published = true # se o usuário completou os 3 passos então o curso está publicado

      # Enfileirando video para conversão
      if @lecture.lectureable_type.eql?('Seminar')
        if @lecture.lectureable.need_transcoding?
          @lecture.lectureable.convert!
        else
          @lecture.lectureable.ready!
        end
      end

      if @space
        if @space.submission_type = 1 # todos podem postar
          params[:lecture][:state] = "approved"
        elsif @space.submission_type = 2 # todos com moderação
          params[:lecture][:state] = "waiting"
        elsif @space.submission_type = 3 # apenas professores
          if current_user.can_post @space
            params[:lecture][:state] = "rejected"
          else
            params[:lecture][:state] = "approved"
          end
        else
          params[:lecture][:state] = "approved"
        end
      else #publico
        params[:lecture][:state] = "waiting"
      end

      respond_to do |format|

        if @lecture.update_attributes(params[:lecture])
          # remover curso da sessao
          session[:lecture_id] = nil
          if @lecture.lectureable_type == 'Seminar' or  @lecture.lectureable_type == 'InteractiveClass'

            format.html do
              if @space
                if @space.submission_type = 1 # todos podem postar
                  #mostra aulas da escola
                  flash[:notice] = 'Aula foi criada com sucesso e está disponível na rede.'
                  redirect_to space_lectures_path(:space_id => params[:post_to].to_i, :id => @lecture.id)

                elsif @space.submission_type = 2 # todos com moderação
                  flash[:notice] = 'Aula foi criada com sucesso e está em processo de moderação.'
                  redirect_to waiting_user_lectures_path(current_user.id)
                elsif @space.submission_type = 3 # apenas professores
                  flash[:notice] = 'Aula não pode ser publicada nessa escola pois apenas professores podem postar.'
                  redirect_to @lecture
                else
                  redirect_to space_lecture_path(:space_id => params[:post_to].to_i, :id => @lecture.id)
                end


              else
                flash[:notice] = 'Aula foi criada com sucesso e está em processo de moderação.'
                redirect_to waiting_user_lectures_path(current_user.id)
              end
            end
          else
            flash[:notice] = 'Aula foi criada com sucesso!'
            format.html do
              redirect_to(@lecture)
            end
          end
        else
          format.html { render "step3" }
        end

      end
    end
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
      lecture.destroy if lecture
      session[:lecture_id] = nil
    end

    flash[:notice] = "Criação de aula cancelada."
    redirect_to lectures_path
  end

  # PUT /lectures/1
  # PUT /lectures/1.xml
  def update

    @lecture = Lecture.find(params[:id])

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
        if @lecture.update_attributes(params[:lecture])
          flash[:notice] = 'Curso atualizado com sucesso.'
          format.html { redirect_to(@lecture) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit_page" }
          format.xml  { render :xml => @lecture.errors, :status => :unprocessable_entity }
        end
      end
    else # seminar
      respond_to do |format|
        if @lecture.update_attributes(params[:lecture])
          flash[:notice] = 'Curso atualizado com sucesso.'
          format.html { redirect_to(@lecture) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit_seminar" }
          format.xml  { render :xml => @lecture.errors, :status => :unprocessable_entity }
        end
      end

    end

  end

  # DELETE /lectures/1
  # DELETE /lectures/1.xml
  def destroy
    @lecture = Lecture.find(params[:id])
    @lecture.destroy
    flash[:notice] = 'A aula foi removida'

    respond_to do |format|
      format.html { redirect_to(lectures_url) }
      format.xml  { head :ok }
    end
  end

  #Buy one lecture
  def buy
    @lecture = Lecture.find(params[:id])

    if not current_user.has_access_to_lecture(@lecture)

      if current_user.has_credits_for_lecture(@lecture)
        #o nome dessa variável, deixar como acquisition
        @acquisition = Acquisition.new
        @acquisition.acquired_by_type = "User"
        @acquisition.acquired_by_id = current_user.id
        @acquisition.value =  Lecture.price
        @acquisition.lecture = @lecture

        if @acquisition.save
          flash[:notice] = 'A aula foi comprada!'
          redirect_to @lecture
        end
      else
        flash[:notice] = 'Você não tem créditos suficientes para comprar esta aula. Recarrege agora!'
        # TODO passar como parametro url da aula para retornar após compra
        redirect_to credits_path(:lecture_id => @lecture.id)
      end
    else
      flash[:notice] = 'Você já possui acesso a esta aula!'
      redirect_to @lecture
    end
  end

  # lista cursos não publicados (em edição)
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

  def notify
    #TODO
  end

  protected
  def authenticate
    authenticate_or_request_with_http_basic do |id, password|
      id == 'zencoder' && password == 'sociallearning'
    end
  end
end
