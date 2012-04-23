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
            if s.class.to_s == "Log"
              false
            else
              can? :read, s.user
            end
          end
          can :destroy, Status do |s|
            if s.class.to_s == "Log"
              false
            else
              can? :manage, s.user
            end
          end
        end

      end
    end
  end
end
