class ResultsController < BaseController
  load_resource :exercise
  load_resource :result

  def create
    @result = @exercise.start_for(current_user)

    respond_to do |format|
      format.html do
        redirect_to exercise_question_path(@exercise, @exercise.questions.first)
      end
    end
  end

  def update
    @exercise.finalize_for(current_user)
    @subject = @exercise.lecture.subject
    @space = @subject.space

    respond_to do |format|
      format.html do
        redirect_to \
          space_subject_lecture_path(@space, @subject, @exercise.lecture)
      end
    end
  end
end
