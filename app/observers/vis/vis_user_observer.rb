class VisUserObserver < ActiveRecord::Observer
  include EnrollmentVisNotification

  observe :user

  #def before_destroy(user)
  #  finalized = []
  #  user.enrollments.each do |enroll|
  #    finalized << enroll if enroll.try(:graduated)
  #  end

  #  delay_hierarchy_notification(user.enrollments.compact, "remove_enrollment")
  #  delay_hierarchy_notification(finalized.compact, "remove_subject_finalized")
  #end
end
