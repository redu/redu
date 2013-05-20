# -*- encoding : utf-8 -*-
module Api
  module FriendshipAbility
    extend ActiveSupport::Concern

    def friendship_abilities(user)
      if user
        can :manage, Friendship, :user_id => user.id
      end
    end
  end
end
