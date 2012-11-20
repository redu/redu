require 'spec_helper'

describe ExerciseVisNotification do
  before do
    @exercise = Factory(:complete_exercise)
    @lecture = Factory(:lecture, :lectureable => @exercise)
    @user = Factory(:user)
    @exercise.start_for(@user)
  end

  context "-Result- after update" do

    context "when 'finalized' is set" do
      it "should send a 'exercise_finalized' notification" do
        result = nil
        WebMock.disable_net_connect!
        ActiveRecord::Observer.with_observers(:result_observer) do
          vis_stub_request

          result = @exercise.finalize_for(@user)
        end
        params = fill_params(@exercise, result, false)

        vis_a_request(params).should have_been_made
      end
    end

    context "when not finalized" do
      it "should not send any notification" do
        exercise2 = Factory(:complete_exercise)
        lecture2 = Factory(:lecture, :lectureable => exercise2)
        WebMock.disable_net_connect!
        ActiveRecord::Observer.with_observers(:result_observer) do
          vis_stub_request

          exercise2.start_for(@user)
        end

        vis_a_request.should_not have_been_made
      end
    end
  end

  context "-Lecture- after destroy" do
    it "when is an Exercise should send a 'remove_exercise_finalized' notification" do
      result = @exercise.finalize_for(@user)
      params = fill_params(@exercise, result, true)

      WebMock.disable_net_connect!
      ActiveRecord::Observer.with_observers(:vis_lecture_observer) do
        vis_stub_request

        @lecture.destroy
      end

      vis_a_request(params).should have_been_made
    end

    it "when isn't an Exercise should not send a 'remove_exercise_finalized' notification" do
      lecture2 = Factory(:lecture)
      WebMock.disable_net_connect!
      ActiveRecord::Observer.with_observers(:vis_lecture_observer) do
        vis_stub_request

        lecture2.destroy
      end

      vis_a_request.should_not have_been_made
    end
  end

  def fill_params(exercise, result, destroy_exercise)
    space = exercise.lecture.subject.space
    params = {
      :lecture_id => exercise.lecture.id,
      :subject_id => exercise.lecture.subject.id,
      :space_id => space.id,
      :course_id => space.course.id,
      :user_id => result.user_id,
      :type => destroy_exercise ? "remove_exercise_finalized" : "exercise_finalized",
      :grade => result.grade.to_f.to_s,
      :status_id => nil,
      :statusable_id => nil,
      :statusable_type => nil,
      :in_response_to_id => nil,
      :in_response_to_type => nil,
      :created_at => result.created_at,
      :updated_at => result.updated_at
    }
  end
end


