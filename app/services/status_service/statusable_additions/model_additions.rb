# -*- encoding : utf-8 -*-
module StatusService
  module StatusableAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def activities
        aggregator = "StatusService::#{self.class}Aggregator".constantize
        status_service.activities(aggregator.new(self))
      end
    end
  end
end
