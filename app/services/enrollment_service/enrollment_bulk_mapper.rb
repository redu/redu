module EnrollmentService
  class EnrollmentBulkMapper < BulkMapper
    def initialize
      columns = [:user_id, :subject_id, :role]
      options = { :validate => false, :on_duplicate_key_update => [:role] }

      super Enrollment, columns, options
    end
  end
end
