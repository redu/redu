class LogObserver < ActiveRecord::Observer

  def after_create(log)
    # Compõe apenas logs com logeable Friendship e UserCourseAssociation
    job = CompoundLogJob.new(log.id)
    Delayed::Job.enqueue(job, :queue => 'general')
  end
end
