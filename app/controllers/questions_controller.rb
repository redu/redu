class QuestionsController < BaseController
  before_filter :load_hierarchy

  def show
    @first_question = @question.first_item
    @last_question = @question.last_item
    @choice = @question.choices.
      first(:conditions => { :user_id => current_user.id}) || @question.choices.build
    @result = @exercise.result_for(current_user)
    @can_manage_lecture = can?(:manage, @lecture)
    @review = !@result.nil? || @can_manage_lecture

    respond_to do |format|
      format.html
    end
  end

  protected

  def load_hierarchy
    @question = Question.find(params[:id])
    @exercise = @question.exercise
    @lecture = @exercise.lecture
    @subject = @lecture.subject
    @space = @subject.space
    @course = @space.course
    @environment = @course.environment
  end
end
