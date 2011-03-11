class SubjectsController < BaseController
  layout 'environment'

  load_and_authorize_resource :space
  load_and_authorize_resource :subject, :through => :space, :except => [:update, :destroy]
  load_and_authorize_resource :subject, :only => [:update, :destroy]

  before_filter :load_course_and_environment
  after_filter :create_activity, :only => [:update]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"

    if params[:action] == 'infos' || !params[:id]
      redirect_to environment_course_path(@space.course.environment, @space.course)
    else
      subject = Subject.find(params[:id])
      redirect_to infos_space_subject_path(@space, subject)
    end
  end

  def index
    if can? :manage, @space
      @subjects = @space.subjects.paginate(:page => params[:page],
                                           :order => 'updated_at DESC',
                                           :per_page => AppConfig.items_per_page)
    else
      @subjects = @space.subjects.published.
        paginate(:page => params[:page],
                 :order => 'updated_at DESC',
                 :per_page => AppConfig.items_per_page)
    end

    respond_to do |format|
      format.html do
        render :template => 'subjects/new/index', :layout => 'new/application'
      end
      format.js do
        render :template => 'subjects/new/index'
      end
    end
  end

  def show
    @statuses = @subject.recent_activity(params[:page])
    @statusable = @subject

    respond_to do |format|
      @status = Status.new

      format.html { render :template => "subjects/new/show", :layout => "new/application" }
      format.js { render :template => 'subjects/new/show' }
      format.xml { render :xml => @subject }
    end
  end

  def new
    @subject = Subject.new
    respond_to do |format|
      format.html do
        render :template => 'subjects/new/new', :layout => 'new/application'
      end
      format.js do
        render :update do |page|
          page.insert_html :before, 'subjects_list',
            :partial => 'subjects/new/form'
          page.hide 'link-new-subject'
        end
      end
    end
  end

  def create
    @subject = Subject.new(params[:subject])
    @subject.owner = current_user
    @subject.space = Space.find(params[:space_id])

    respond_to do |format|
      if @subject.save
        format.js do
          render :template => 'subjects/new/create'
        end
      else
        format.js do
          # Workaround para mostrar o errors.full_messages
          errors_full = "<ul>"
          @subject.errors.full_messages.each do |error|
            errors_full += "<li>#{error}</li>"
          end
          errors_full += "</ul>"

          render :update do |page|
            page.remove '#errorExplanation > ul'
            page.insert_html :bottom,  '#errorExplanation', errors_full
            page.show 'errorExplanation'
            page.replace_html 'subject_title-error', @subject.errors.on(:title)
            page.show 'subject_title-error'
            page.replace_html 'subject_description-error', @subject.errors.on(:description)
            page.show 'subject_description-error'
          end
        end
      end
    end
  end

  def edit
    @subject_header = @subject.clone
    @admin_panel = true if params[:admin_panel]
    respond_to do |format|
      format.html do
        render :template => "subjects/new/edit", :layout=> "new/application"
      end
      format.js do
        render :update do |page|
          page.hide 'content'
          page.insert_html :before, 'content',
            :partial => 'subjects/new/form'
        end
      end
    end
  end

  def update
    @subject_header = @subject.clone

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        if @subject.finalized?
          flash[:notice] = "As atualizações foram salvas."
        else
          @subject.finalized = true
          @subject.published = true
          @subject.save
          @subject.convert_lectureables!
          flash[:notice] = "O Módulo foi criado."
        end

        format.js do
          render :update do |page|
            page.redirect_to(:controller => 'subjects', :action => 'index',
                             :space_id => @subject.space.id)
          end
        end
        format.html { redirect_to space_subject_path(@space, @subject) }
      else
        format.js { render :template => 'subjects/new/update_error' }
        format.html do
          render :template => "subjects/new/edit", :layout=> "new/application"
        end
      end
    end
  end

  def destroy
    @subject.destroy
    if params[:building_subject]
      flash[:notice] = "A construção do módulo foi cancelada."
    else
      flash[:notice] = "O módulo foi removido."
    end
    redirect_to space_subjects_path(@subject.space)
  end

  def infos
    respond_to do |format|
      format.html { render :template => 'subjects/new/infos',
        :layout => 'new/application' }
    end
  end

  def publish
    @subject.publish!
    flash[:notice] = "O módulo foi publicado."
    redirect_to space_subject_path(@space, @subject)
  end

  def unpublish
    @subject.unpublish!
    flash[:notice] = "O módulo foi despublicado e todas as matrículas foram perdidas."
    redirect_to space_subject_path(@space, @subject)
  end

  def enroll
    role = current_user.get_association_with(@space).role
    @subject.enroll(current_user, role)
    flash[:notice] = "Você foi matriculado e já pode começar a assistir as aulas."
    redirect_to space_subject_path(@space, @subject)
  end

  def unenroll
    if params.has_key?(:users)
      params[:users].each do |user_id|
        user = User.find(user_id)
        @subject.unenroll(user)
      end
    else
      user = User.find(params[:user_id])
      @subject.unenroll(user)
    end
    flash[:notice] = "Você desmatriculado do módulo."
    redirect_to admin_members_space_subject_path(@space, @subject)
  end

  #FIXME evitar usar GET e POST no mesmo action
  def admin_lectures_order
    unless request.post?
      respond_to do |format|
        format.html do
          render :template => 'subjects/new/admin_lectures_order',
            :layout => 'new/application' and return
        end
      end
    end

    lectures_ordered = params[:lectures_ordered].split(",")
    @subject.change_lectures_order!(lectures_ordered)

    flash[:notice] = "A ordem das aulas foi atualizada."
    respond_to do |format|
      format.html do
        redirect_to admin_lectures_order_space_subject_path(@space, @subject)
      end
    end
  end

  def admin_members
    @memberships = @subject.members.paginate(:page => params[:page],
                                :order => 'first_name ASC',
                                :per_page => AppConfig.items_per_page)
    respond_to do |format|
      format.html do
        render :template => "subjects/new/admin_members",
               :layout=> "new/application"
      end
      format.js { render :template => "subjects/new/admin_members" }
    end
  end

  def next_lecture
    if params[:done] == "0"
      done = false
    else
      done = true
    end
    lecture = Lecture.find(params[:lecture_id])
    @lecture = lecture.next_for(current_user, done)
    enrollment = current_user.get_association_with(@subject)
    enrollment.student_profile.update_grade!

    if @lecture
      redirect_to space_subject_lecture_path(@space, @subject, @lecture)
    else
      redirect_to space_subject_lecture_path(@space, @subject)
    end
  end

  # Mural do Subject
  def statuses
    @status = Status.new
    @statusable = @subject
    @statuses = @subject.recent_activity(params[:page])

    respond_to do |format|
      format.html
      format.js { render :template => "statuses/index"}
    end
  end

  # Listagem de usuários do Space
  def users
    @users = @subject.members.
      paginate(:page => params[:page], :order => 'first_name ASC', :per_page => 18)

    respond_to do |format|
      format.html do
        render :template => 'subjects/new/users', :layout => 'new/application'
      end
      format.js { render :template => 'subjects/new/users' }
    end
  end


  protected

  def load_course_and_environment
    unless @space
      if @subject
        @space = @subject.space
      else
        @space = Space.find(params[:space_id])
      end
    end
    @course = @space.course
    @environment = @course.environment
  end
end
