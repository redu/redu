class SubjectObserver < ActiveRecord::Observer
  def after_update(model)
    # model.notify_subject_added
    notification = NotifySubjectAddedJob.new(:subject_id => model)
    Delayed::Job.enqueue(notification, :queue => 'email')
  end
end
