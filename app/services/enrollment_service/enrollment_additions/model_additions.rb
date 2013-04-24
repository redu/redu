module EnrollmentService
  module EnrollmentAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def update_grade!
        notify_vis_if_enrollment_change do
          service_facade.update_grade(self)
        end
      end

      private

      def notify_vis_if_enrollment_change(&block)
        prev_graduated = self.graduated
        prev_grade = self.grade

        yield

        self.reload

        if finalized_subject?(prev_graduated, prev_grade)
          service_facade.notify_subject_finalized(self)
        elsif unfinalized_subject?(prev_graduated, prev_grade)
          service_facade.notify_remove_subject_finalized(self)
        end
      end

      def finalized_subject?(prev_graduated, prev_grade)
        self.graduated? && (prev_grade != self.grade)
      end

      def unfinalized_subject?(prev_graduated, prev_grade)
        !self.graduated? && ((prev_grade != self.grade) && (prev_grade == 100))
      end

      def service_facade
        EnrollmentService::Facade.instance
      end
    end
  end
end
