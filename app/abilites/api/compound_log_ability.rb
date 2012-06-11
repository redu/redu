module Api
  module CompoundLogAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def compound_log_abilities(user)
        false
      end
    end
  end
end


