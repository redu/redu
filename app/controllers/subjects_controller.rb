class SubjectsController < BaseController
  respond_to :html, :js

  load_and_authorize_resource :space
  load_and_authorize_resource :subject, :through => :space, :except => [:update, :destroy]
  load_and_authorize_resource :subject, :only => [:update, :destroy]

  before_filter :load_course_and_environment

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"

    redirect_to preview_environment_course_path(@space.course.environment,
                                                @space.course)
  end

  def new
    @subject = Subject.new
    @quota = @course.quota
    @plan = @course.plan

    respond_to do |format|
      format.html { render "subjects/admin/new" }
    end
  end

  def create
    @subject = Subject.new(params[:subject])
    @subject.owner = current_user
    @subject.space = Space.find(params[:space_id])
    @subject.save

    @quota = @course.quota
    @plan = @course.plan

    respond_with(@subject.space, @subject, :layout => !request.xhr?) do |format|
      format.js { render "subjects/admin/create" }
    end
  end

  def edit
    @editable_lectures = @subject.lectures.pages | @subject.lectures.exercises
    @quota = @course.quota
    @plan = @course.plan

    respond_to do |format|
      format.html { render "subjects/admin/edit" }
    end
  end

  def update
    @quota = @course.quota
    @plan = @course.plan

    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        if @subject.finalized?

          unless params[:lectures_order].blank?
            lectures_order = params[:lectures_order].split(",")
            ids_order = lectures_order.collect do |item|
              item.split("-")[0].to_i # Remove '-item'
            end
            @subject.change_lectures_order!(ids_order)
          end

          flash[:notice] = "As atualizações foram salvas."
        else
          @subject.finalized = true
          @subject.save
          # cria as associações com o subject, replicando a do space
          @subject.create_enrollment_associations
          flash[:notice] = "O Módulo foi criado."
        end

        format.html { redirect_to space_path(@space) }
      else
        format.html do
          render "subjects/admin/edit"
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
    redirect_to space_path(@subject.space)
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
