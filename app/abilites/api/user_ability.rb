module Api
  module UserAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def user_abilities(user)
        if user
          can :manage, User, :id => user.id
        else
          cannot :read, User
        end
      end
    end
  end
end
