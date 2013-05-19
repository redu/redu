module Api
  module UserAbility
    extend ActiveSupport::Concern

    def user_abilities(user)
      if user
        can :manage, User, :id => user.id
        can(:read, User) { |u| user.friends? u }
      end
    end
  end
end
