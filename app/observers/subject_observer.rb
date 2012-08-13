class SubjectObserver < ActiveRecord::Observer
  def after_update(model)
    # model.notify_subject_added
    notification = NotifySubjectAddedJob.new(:subject_id => model)
    Delayed::Job.enqueue(notification, :queue => 'email')

    # Cria enrollments caso o subject tenha sido finalizado
    if (model.finalized_changed? & model.finalized == true)
      job = CreateEnrollmentJob.new(:subject_id => model.id)
      Delayed::Job.enqueue(job, :queue => 'general')
    end
  end
end
