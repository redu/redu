module Api
  module ChatAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def chat_abilities(user)
        if user
          can :manage, Chat, :user_id => user.id
        end
      end
    end
  end
end
