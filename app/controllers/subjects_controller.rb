class SubjectsController < BaseController
  layout 'environment'

  load_resource :space
  load_and_authorize_resource :subject

  before_filter :load_course_and_environment

  def index
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
     redirect_to space_subjects_path(@subject.space)
   else
     render :edit
   end
  end

  def destroy
   @subject.destroy
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
