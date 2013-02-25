class VisEnrollmentObserver < ActiveRecord::Observer
  include EnrollmentVisNotification
  observe :enrollment

  def before_update(enrollment)
    if enrollment.graduated? and enrollment.grade_changed?
      notify_vis(enrollment, "subject_finalized")
    elsif !enrollment.graduated? and enrollment.changed_attributes['grade'] == 100
      notify_vis(enrollment, "remove_subject_finalized")
    end
  end
end
