# -*- enconding : utf-8 -*-
module EnrollmentService
  module UserAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      included do
        before_destroy :destroy_asset_reports, :destroy_enrollments
      end

      private

      def destroy_asset_reports
        lectures = Lecture.where(subject_id: subjects_ids)
        enrollment_service.destroy_asset_report(lectures, self.enrollments)
      end

      def destroy_enrollments
        subjects = Subject.where(id: subjects_ids)
        enrollment_service.destroy_enrollment(subjects, self)
      end

      def subjects_ids
        self.enrollments.values_of(:subject_id)
      end
    end
  end
end
