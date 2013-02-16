module ExerciseVisNotification
  include VisClient

  def send_to_vis(result, destroy_exercise)
    params = build_hash_to_vis(result, destroy_exercise)
    #send_async_info(params, Redu::Application.config.vis_client[:url])
  end

  protected

  def build_hash_to_vis(result, destroy_exercise)
    exercise = result.exercise
    space = exercise.lecture.subject.space
    params = {
      :lecture_id => exercise.lecture.id,
      :subject_id => exercise.lecture.subject.id,
      :space_id => space.id,
      :course_id => space.course.id,
      :user_id => result.user_id,
      :type => destroy_exercise ? "remove_exercise_finalized" : "exercise_finalized",
      :grade => result.grade,
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
