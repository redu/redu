class EnrollmentObserver < ActiveRecord::Observer
  include EnrollmentVisNotification

  def before_update(enrollment)
    if enrollment.graduated? and enrollment.grade_changed?
      notify_vis(enrollment, "subject_finalized")
    elsif !enrollment.graduated? and enrollment.changed_attributes['grade'] == 100
      notify_vis(enrollment, "remove_subject_finalized")
    end
  end
end
