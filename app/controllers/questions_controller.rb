class QuestionsController < BaseController
  before_filter :load_hierarchy

  def show
    @first_question = @question.first_item
    @last_question = @question.last_item

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
