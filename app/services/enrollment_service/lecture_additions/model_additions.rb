module EnrollmentService
  module LectureAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def create_asset_report
        delayed_create_asset_report
      end

      private

      def delayed_create_asset_report
        enrollments = self.subject.enrollments
        job = Jobs::CreateAssetReportJob.
          new(:lecture => [self], :enrollment => enrollments)
        enqueue(job)
      end

      def enqueue(job)
        Delayed::Job.enqueue(job, :queue => "hierachy-associations")
      end

      def service_facade
        Facade.instance
      end
    end
  end
end
