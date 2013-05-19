module Api
  module EnvironmentAbility
    extend ActiveSupport::Concern

    def environment_abilities(user)
      if user
        @admin_role ||= Role[:environment_admin]
        @non_admin_roles ||= [Role[:member], Role[:teacher], Role[:tutor]]
        can :manage, Environment do |context|
          context.user_environment_associations.
            exists?(:user_id => user, :role => @admin_role)
        end
        can :read, Environment do |context|
          context.user_environment_associations.
            exists?(:user_id => user, :role => @non_admin_roles)
        end
      end
    end
  end
end
