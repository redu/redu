class SubjectsController < BaseController
  respond_to :html, :js

  load_and_authorize_resource :space
  load_and_authorize_resource :subject, :through => :space, :except => [:update, :destroy]
  load_and_authorize_resource :subject, :only => [:update, :destroy]

  before_filter :load_course_and_environment
  after_filter :create_activity, :only => [:update]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"

    redirect_to preview_environment_course_path(@space.course.environment,
                                                @space.course)
  end

  def index
    if can? :manage, @space
      @subjects = @space.subjects.paginate(:page => params[:page],
                                           :order => 'updated_at DESC',
                                           :per_page => Redu::Application.config.items_per_page)
    else
      @subjects = @space.subjects.visible.
        paginate(:page => params[:page],
                 :order => 'updated_at DESC',
                 :per_page => Redu::Application.config.items_per_page)
    end

    respond_to do |format|
      format.html
      format.js { render_endless 'subjects/item', @subjects, '#subjects_list' }
    end
  end

  def show
    @statuses = @subject.recent_activity(params[:page])
    @statusable = @subject

    respond_to do |format|
      @status = Status.new

      format.html
      format.js { render_endless 'statuses/item', @statuses, '#statuses > ol' }
      format.xml { render :xml => @subject }
    end
  end

  def new
    @subject = Subject.new

    respond_to do |format|
      format.html
    end
  end

  def create
    @subject = Subject.new(params[:subject])
    @subject.owner = current_user
    @subject.space = Space.find(params[:space_id])
    @subject.save

    respond_with(@subject.space, @subject, :layout => !request.xhr?)
  end

  def edit
    @subject_header = @subject.clone
    @admin_panel = true if params[:admin_panel]
    respond_to do |format|
      format.html
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
          @subject.visible = true
          @subject.save
          # cria as associações com o subject, replicando a do space
          @subject.create_enrollment_associations
          flash[:notice] = "O Módulo foi criado."
        end

        format.js
        format.html { redirect_to space_subject_path(@space, @subject) }
      else
        format.js { render :template => 'subjects/update_error' }
        format.html do
          render :edit
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

  def turn_visible
    @subject.turn_visible!
    flash[:notice] = "O módulo está visível para todos."
    redirect_to space_subject_path(@space, @subject)
  end

  def turn_invisible
    @subject.turn_invisible!
    flash[:notice] = "O módulo está invisível, apenas administradores podem visualizá-lo."
    redirect_to space_subject_path(@space, @subject)
  end

  #FIXME evitar usar GET e POST no mesmo action
  def admin_lectures_order
    unless request.post?
      respond_to do |format|
        format.html do
          render :admin_lectures_order and return
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
                                :per_page => Redu::Application.config.items_per_page)
    respond_to do |format|
      format.html
      format.js do
        render_endless 'subjects/user_item_admin', @memberships, '#user_list_table'
      end
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

  # Listagem de usuários do Space
  def users
    @users = @subject.members.paginate(:page => params[:page],
                                       :order => 'first_name ASC',
                                       :per_page => 18)

    respond_to do |format|
      format.html
      format.js do
        render_endless 'users/item', @users, '#users_list',
          { :entity => @subject }
    end
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
