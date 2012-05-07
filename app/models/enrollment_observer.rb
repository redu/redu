class EnrollmentObserver < ActiveRecord::Observer
  include EnrollmentVisNotification

  def before_update(enrollment)
    old_enroll = Enrollment.find(enrollment.id)
    if enrollment.graduaded and old_enroll.grade != enrollment.grade
      notify_vis(enrollment, "subject_finalized")
    elsif enrollment.graduaded == false and old_enroll.grade == 100
      notify_vis(enrollment, "remove_subject_finalized")
    end
  end
end
