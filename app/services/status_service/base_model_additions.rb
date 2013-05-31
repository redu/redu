# -*- enconding : utf-8 -*-
module StatusService
  module BaseModelAdditions
    extend ActiveSupport::Concern

    def status_service
      self.class.status_service
    end

    module ClassMethods
      def status_service
        Facade.instance
      end
    end
  end
end
