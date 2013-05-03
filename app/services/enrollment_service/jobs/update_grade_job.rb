module EnrollmentService
  module Jobs
    class UpdateGradeJob < LinkedJob
      def initialize(opts={})
        options.set(:enrollment, opts.delete(:enrollment))
      end

      def execute
        facade.update_grade(options.arel_of(:enrollment))
        {}
      end
    end
  end
end
