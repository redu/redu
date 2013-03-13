class VisEnrollmentObserver < ActiveRecord::Observer
  include EnrollmentVisNotification
  observe :enrollment

  def before_update(enrollment)
    if enrollment.graduated? and enrollment.grade_changed?
      delay_hierarchy_notification("subject_finalized", enrollment)
    elsif !enrollment.graduated? and enrollment.changed_attributes['grade'] == 100
      delay_hierarchy_notification("remove_subject_finalized",
                                     enrollment)
    end
  end
end
