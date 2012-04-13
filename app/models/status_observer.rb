class StatusObserver < ActiveRecord::Observer
  def after_create(status)
    case status.statusable.class.to_s
    when "User"
      status.user.status_user_associations.create(:status => status)
      job = UserStatusesJob.new(status.user.id, status.id)
      Delayed::Job.enqueue(job, :queue => 'general')
    when "Lecture"
      course = status.statusable.subject.space.course
      job = HierarchyStatusesJob.new(status.id, course.id)
      Delayed::Job.enqueue(job, :queue => 'general')
    when "Space"
      job = HierarchyStatusesJob.new(status.id, status.statusable.course.id)
      Delayed::Job.enqueue(job, :queue => 'general')
    when "Course"
      job = HierarchyStatusesJob.new(status.id, status.statusable.id)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end

  protected
end
