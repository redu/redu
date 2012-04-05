class StatusObserver < ActiveRecord::Observer
  def after_create(status)
    case status.statusable.class.to_s
    when "User"
      status.user.status_user_associations.create(:status => status)
      Delayed::Job.enqueue UserStatusesJob.new(status.user.id, status.id)
    when "Lecture"
      course = status.statusable.subject.space.course
      Delayed::Job.enqueue \
        HierarchyStatusesJob.new(status.id, course.id)
    when "Space"
      Delayed::Job.enqueue \
        HierarchyStatusesJob.new(status.id, status.statusable.course.id)
    when "Course"
      Delayed::Job.enqueue \
        HierarchyStatusesJob.new(status.id, status.statusable.id)
    end
  end

  protected
end
