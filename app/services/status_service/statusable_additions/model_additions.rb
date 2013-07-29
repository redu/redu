# -*- encoding : utf-8 -*-
module StatusService
  module StatusableAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def activities
        aggregator = "StatusService::#{self.class}Aggregator".constantize
        optimized_relation = Status.includes(:user).order("updated_at DESC")

        status_service.activities(aggregator.new(self), optimized_relation)
      end
    end
  end
end
