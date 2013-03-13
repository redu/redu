class VisUserObserver < ActiveRecord::Observer
  include EnrollmentVisNotification

  observe :user

  def before_destroy(user)
    finalized = []
    user.enrollments.each do |enroll|
      finalized << enroll if enroll.try(:graduated)
    end

    delay_hierarchy_notification("remove_enrollment",
                                 user.enrollments.compact)
    delay_hierarchy_notification("remove_subject_finalized",
                                 finalized.compact)
  end
end
