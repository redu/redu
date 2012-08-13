class StatusObserver < ActiveRecord::Observer
  include StatusVisNotification

  def after_create(status)
    unless status.is_a? CompoundLog
      case status.statusable.class.to_s
      when "User"
        status.user.status_user_associations.create(:status => status)
        job = UserStatusesJob.new(status.user.id, status.id)
        Delayed::Job.enqueue(job, :queue => 'general')
      when "Lecture"
        course = status.statusable.subject.space.course
        job = HierarchyStatusesJob.new(status.id, course.id)
        Delayed::Job.enqueue(job, :queue => 'general')

        # Used to send information to vis application
        send_to_vis(status, false)
      when "Space"
        job = HierarchyStatusesJob.new(status.id, status.statusable.course.id)
        Delayed::Job.enqueue(job, :queue => 'general')

        # Used to send information to vis application
        send_to_vis(status, false)
      when "Course"
        job = HierarchyStatusesJob.new(status.id, status.statusable.id)
        Delayed::Job.enqueue(job, :queue => 'general')
      when "Activity", "Help"
        unless status.statusable.statusable.is_a? User
          send_to_vis(status, false)
        end
      end
    end
  end
end
