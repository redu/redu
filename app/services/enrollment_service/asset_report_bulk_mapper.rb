module EnrollmentService
  class AssetReportBulkMapper < BulkMapper
    def initialize
      columns = [:subject_id, :lecture_id, :enrollment_id]
      options = { :validate => false, :on_duplicate_key_update => [:done] }

      super AssetReport, columns, options
    end
  end
end
