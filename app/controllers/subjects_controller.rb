class SubjectsController < BaseController
  layout 'environment'

  load_resource :space
  load_and_authorize_resource :subject

  before_filter :load_course_and_environment

  def index
    if params[:building_subject]
      flash[:notice] = "O Módulo foi criado."
    end
    @subjects = @space.subjects.paginate(:page => params[:page],
                                        :order => 'updated_at DESC',
                                        :per_page => AppConfig.items_per_page)
  end

  def show

  end

  def new
    @subject = Subject.new
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

  def update
   if @subject.update_attributes(params[:subject])
     render :update do |page|
      page.redirect_to(:controller => 'subjects', :action => 'index',
                       :space_id => @subject.space.id,
                       :building_subject => true)
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
