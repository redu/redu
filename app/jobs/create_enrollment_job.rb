class CreateEnrollmentJob
  attr_accessor :subject_id

  def initialize(opts)
    @subject_id = opts[:subject_id]
  end

  def perform
    subject = Subject.find_by_id(@subject_id)
    subject.enroll if subject
  end

end
