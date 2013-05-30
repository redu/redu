# -*- enconding : utf-8 -*-
module EnrollmentService
  module BaseModelAdditions
    extend ActiveSupport::Concern

    def enrollment_service
      self.class.enrollment_service
    end

    module ClassMethods
      def enrollment_service
        Facade.instance
      end
    end
  end
end
