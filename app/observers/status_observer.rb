# -*- encoding : utf-8 -*-
class StatusObserver < ActiveRecord::Observer

  def after_create(status)
    unless status.is_a? CompoundLog
      case status.statusable.class.to_s
      when "User"
        status.user.status_user_associations.create(:status => status)
        job = UserStatusesJob.new(:user_id => status.user.id,
                                  :status_id => status.id)
        Delayed::Job.enqueue(job, :queue => 'general')
      when "Lecture"
        course = status.statusable.subject.space.course
        job = HierarchyStatusesJob.new(:status_id => status.id, :course_id => course.id)
        Delayed::Job.enqueue(job, :queue => 'general')

      when "Space"
        job = HierarchyStatusesJob.new(:status_id => status.id,
                                       :course_id => status.statusable.course.id)
        Delayed::Job.enqueue(job, :queue => 'general')

      when "Course"
        job = HierarchyStatusesJob.new(:status_id => status.id,
                                       :course_id => status.statusable.id)
        Delayed::Job.enqueue(job, :queue => 'general')
      end
    end
  end
end
