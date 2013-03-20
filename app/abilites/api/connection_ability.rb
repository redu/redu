module Api
  module ConnectionAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def connection_abilities(user)
        if user
          can :manage, Friendship, :user_id => user.id
          can :read, Friendship do |f|
            f.user == user
          end
        end
      end
    end
  end
end
