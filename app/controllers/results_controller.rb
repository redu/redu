class ResultsController < BaseController
  load_resource :exercise

  def create
    @result = @exercise.start_for(current_user)

    respond_to do |format|
      format.html do
        redirect_to exercise_question_path(@exercise, @exercise.questions.first)
      end
    end
  end
end
