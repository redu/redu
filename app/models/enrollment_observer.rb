class EnrollmentObserver < ActiveRecord::Observer
  include VisClient

  def before_update(enrollment)
    old_enroll = Enrollment.find(enrollment.id)
    if enrollment.grade == 100 and old_enroll.grade != enrollment.grade
      notify_vis(enrollment)
    end
  end

  protected

  def notify_vis(enrollment)
    params = {
      :user_id => enrollment.user_id,
      :lecture_id => nil,
      :subject_id => enrollment.subject_id,
      :space_id => enrollment.subject.space.id,
      :course_id => enrollment.subject.space.course.id,
      :type => "subject_finalized",
      :status_id => nil,
      :statusable_id => nil,
      :statusable_type => nil,
      :in_response_to_id => nil,
      :in_response_to_type => nil,
      :created_at => enrollment.created_at,
      :updated_at => enrollment.updated_at
    }

    self.send_async_info(params, Redu::Application.config.vis_client[:url])
  end

end
