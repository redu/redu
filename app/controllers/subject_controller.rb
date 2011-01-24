class SubjectController < BaseController
  load_resource :space
  load_and_authorize_resource :subject

  def index
    @subjects = @space.subjects
  end

  def show

  end

  def new
    @subject = Subject.new
  end

  def create
    @subject = Subject.new(params[:subject])
    @subject.owner = current_user
    if @subject.save
      redirect_to edit_space_subject_path(@subject.space, @subject)
    else
      render :new
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

end
