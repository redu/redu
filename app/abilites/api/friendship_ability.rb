module Api
  module FriendshipAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def friendship_abilities(user)
        if user
          can :manage, Friendship, :user_id => user.id
        end
      end
    end
  end
end
