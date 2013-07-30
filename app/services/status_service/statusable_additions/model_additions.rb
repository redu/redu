# -*- encoding : utf-8 -*-
module StatusService
  module StatusableAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      def activities
        aggregator_class = "StatusService::#{self.class}Aggregator".constantize
        @status_aggregator ||= aggregator_class.new(self)
        optimized_relation = Status.includes(:user).order("updated_at DESC")

        status_service.activities(@status_aggregator, optimized_relation)
      end
    end
  end
end
