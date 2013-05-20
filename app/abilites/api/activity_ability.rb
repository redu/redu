# -*- encoding : utf-8 -*-
module Api
  module ActivityAbility
    extend ActiveSupport::Concern

    def activity_abilities(user)
      if user
        can :manage, Activity, :user_id => user.id
        can :manage, Activity do |a|
          can? :manage, a.statusable
        end
        can :read, Activity do |a|
          can? :read, a.statusable
        end
      end
    end
  end
end
