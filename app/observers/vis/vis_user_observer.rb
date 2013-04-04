class VisUserObserver < ActiveRecord::Observer
  observe :user

  def before_destroy(user)
    finalized = []
    enrollments = user.enrollments
    enrollments.each do |enroll|
      finalized << enroll if enroll.try(:graduated)
    end

    VisClient.notify_delayed("/hierarchy_notifications.json",
                             "remove_enrollment", enrollments.compact)
    VisClient.notify_delayed("/hierarchy_notifications.json",
                             "remove_subject_finalized", finalized.compact)
  end
end
