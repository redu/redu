module Api
  module StatusAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def status_abilities(user)
        if user
          can :read, Status do |s|
              can? :read, s.user
          end
          can :create, Status do |s|
              can? :read, s.user
          end
          can :destroy, Status do |s|
              can? :manage, s.user
          end
        end

      end
    end
  end
end
