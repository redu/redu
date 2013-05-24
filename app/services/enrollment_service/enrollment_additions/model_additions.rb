# -*- encoding : utf-8 -*-
module EnrollmentService
  module EnrollmentAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def update_grade!
        enrollment_service.update_grade(self)
      end
    end
  end
end
