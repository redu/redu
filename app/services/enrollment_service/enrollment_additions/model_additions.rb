# -*- encoding : utf-8 -*-
module EnrollmentService
  module EnrollmentAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def update_grade!
        service_facade.update_grade(self)
      end

      private

      def service_facade
        EnrollmentService::Facade.instance
      end
    end
  end
end
