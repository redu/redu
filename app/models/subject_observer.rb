class SubjectObserver < ActiveRecord::Observer
  def after_update(model)
    # model.notify_subject_added
    notification = NotifySubjectAddedJob.new(:subject_id => model)
    Delayed::Job.enqueue(notification, :queue => 'email')
  end

  def after_create(subject)
    job = CreateEnrollmentJob.new(:subject_id => subject.id)
    Delayed::Job.enqueue(job, :queue => 'general')
  end
end
