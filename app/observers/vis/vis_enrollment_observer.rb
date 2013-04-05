class VisEnrollmentObserver < ActiveRecord::Observer
  observe :enrollment

  def before_update(enrollment)
    if enrollment.graduated? and enrollment.grade_changed?
      VisClient.notify_delayed("/hierarchy_notifications.json",
                               "subject_finalized", enrollment)
    elsif !enrollment.graduated? and enrollment.changed_attributes['grade'] == 100
      VisClient.notify_delayed("/hierarchy_notifications.json",
                               "remove_subject_finalized",
                               enrollment)
    end
  end
end
