module Api
  module LogAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def log_abilities(user)
        if user
          can :read, Log, :user_id => user.id
          can :read, Log do |log|
            can? :read, log.statusable
          end
        end
      end
    end
  end
end

