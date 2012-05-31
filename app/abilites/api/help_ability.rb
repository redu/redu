module Api
  module HelpAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def help_abilities(user)
        if user
          can :manage, Help, :user_id => user.id
          can(:manage, Help) { |help| can? :manage, help.statusable }
          can(:read, Help) { |h| can? :read, h.statusable }
        end
      end
    end
  end
end
