class NotifySubjectAddedJob
  def initialize(opts)
    @subject_id = opts[:subject_id]
  end

  def perform
    subject = Subject.find_by_id(@subject_id)
    subject.notify_subject_added if subject
  end
end
