class SubjectsController < BaseController
  layout 'environment'

  load_resource :space
  load_and_authorize_resource :subject, :through => :space, :except => [:update]
  load_and_authorize_resource :subject, :only => [:update]

  before_filter :load_course_and_environment
  after_filter :create_activity, :only => [:update]

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"
    redirect_to infos_space_subject_path(@space, @subject)
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
  end

  def show

  end

  def new
    @subject = Subject.new
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :after, 'link-new-subject', :partial => 'subjects/form'
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
        format.js
      else
        format.js do
          render :update do |page|
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
    @admin_panel = true if params[:admin_panel]
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.hide 'content'
          page.insert_html :before, 'content', :partial => 'subjects/form'
        end
      end
    end
  end

  def update
    if @subject.update_attributes(params[:subject])
      if @subject.finalized?
        flash[:notice] = "As atualizações foram salvas."
      else
        @subject.finalized = true
        flash[:notice] = "O Módulo foi criado."
      end
      @subject.save
      render :update do |page|
        page.redirect_to(:controller => 'subjects', :action => 'index',
                         :space_id => @subject.space.id)
      end
    else
      render :template => 'subjects/update_error'
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
    @subject.unenroll(current_user)
    flash[:notice] = "Você desmatriculado do módulo."
    redirect_to space_subject_path(@space, @subject)
  end

  def admin_lectures_order
    return unless request.post?
    lectures_ordered = params[:lectures_ordered].split(",")
    @subject.change_lectures_order!(lectures_ordered)

    flash[:notice] = "A ordem das aulas foi atualizada."
    redirect_to admin_lectures_order_space_subject_path(@space, @subject)
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
