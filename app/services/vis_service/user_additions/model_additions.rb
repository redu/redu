module VisService
  module UserAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      included do
        before_destroy :send_vis_notifications
      end

      def send_vis_notifications
        enrollments = self.enrollments.compact
        finalized_enrollments = get_finalized_enrollments(enrollments)
        vis_adapter.notify_enrollment_removal(enrollments)
        vis_adapter.notify_remove_subject_finalized(finalized_enrollments)
      end

      private

      def vis_adapter
        @vis_adapter ||= EnrollmentService::VisAdapter.new
      end

      def get_finalized_enrollments(enrollments)
        enrollments.select { |enrollment| enrollment.try(:graduated) }
      end
    end
  end
end
