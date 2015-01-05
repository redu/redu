class ArQuestionsController < ApplicationController
  before_filter :load_hierarchy

  authorize_resource :ar_question

  def show
    @first_ar_question = @ar_question.first_item
    @last_ar_question = @ar_question.last_item

    respond_to do |format|
      format.html
    end

  end


  protected

  def load_hierarchy
    @ar_question = ArQuestion.find(params[:id])
    @exercise = @ar_question.exercise
    @lecture = @exercise.lecture
    @subject = @lecture.subject
    @space = @subject.space
    @course = @space.course
    @environment = @course.environment
  end


end
