# -*- encoding : utf-8 -*-
module StatusService
  module UserAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      included do
        before_destroy :destroy_statuses
      end

      private

      def destroy_statuses
        status_service.destroy_status(self)
      end
    end
  end
end
