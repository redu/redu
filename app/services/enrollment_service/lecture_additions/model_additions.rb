module EnrollmentService
  module LectureAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def create_asset_report
        service_facade.create_asset_report(:lectures => [self])
        service_facade.update_grade(self.subject.enrollments)
      end

      private

      def service_facade
        Facade.instance
      end
    end
  end
end
