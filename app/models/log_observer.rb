class LogObserver < ActiveRecord::Observer

  def after_create(log)
    # Compõe apenas logs com logeable Friendship e UserCourseAssociation
    if ["Friendship", "UserCourseAssociation"].include? log.logeable.class.to_s
      job = CompoundLogJob.new(log.id)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end
end
