class EnrollmentObserver < ActiveRecord::Observer
  include VisClient

  def before_update(enrollment)
    old_enroll = Enrollment.find(enrollment.id)
    if enrollment.graduaded and old_enroll.grade != enrollment.grade
      notify_vis(enrollment, "subject_finalized")
    elsif enrollment.graduaded == false and old_enroll.grade == 100
      notify_vis(enrollment, "remove_subject_finalized")
    end
  end

  protected

  def notify_vis(enrollment, type)
    params = {
      :user_id => enrollment.user_id,
      :lecture_id => nil,
      :subject_id => enrollment.subject_id,
      :space_id => enrollment.subject.space.id,
      :course_id => enrollment.subject.space.course.id,
      :type => type,
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
