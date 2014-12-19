class NotifySubjectUpdateJob
  def initialize(opts)
    @subject_id = opts[:subject_id]
  end

  def perform
    subject = Subject.find_by_id(@subject_id)
    if subject
      subject.notify_subject_update
      Log.setup(subject, :action => :update)
    end
  end
end