module EnrollmentService
  class CreateAssetReportJob < LinkedJob
    def initialize(opts={})
      options.set(:lecture, opts.delete(:lecture))
      options.set(:enrollment, opts.delete(:enrollment))
    end

    def execute
      lectures = options.arel_of(:lecture)
      enrollments = options.arel_of(:enrollment)

      facade.
        create_asset_report(:lectures => lectures, :enrollments => enrollments)

      { :enrollments => enrollments }
    end

    def build_next_job(env)
      UpdateGradeJob.new(:enrollment => env[:enrollments])
    end
  end
end
