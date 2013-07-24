# -*- encoding : utf-8 -*-
class QuestionsController < BaseController
  before_filter :load_hierarchy

  authorize_resource :question

  def show
    @first_question = @question.first_item
    @last_question = @question.last_item
    @choice = @question.choices.
      first(:conditions => { :user_id => current_user.id}) || @question.choices.build
    @result = @exercise.result_for(current_user)
    @can_manage_lecture = can?(:manage, @lecture)
    @review = !@result.nil? || @can_manage_lecture

    if current_user.get_association_with(@lecture.subject)
      asset_report = @lecture.asset_reports.of_user(current_user).first
      @student_grade = asset_report.enrollment.grade.to_i
      @done = asset_report.done
    end

    respond_to do |format|
      format.html { render layout: 'lectures/show' }
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
