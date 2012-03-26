module Api
  module CourseAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def course_abilities(user)
        if user
          @admin_role ||= Role[:environment_admin]
          @non_admin_roles ||= [Role[:member], Role[:teacher], Role[:tutor]]

          can :manage, Course do |c|
            c.user_course_associations.
              exists?(:user_id => user, :role => @admin_role)
          end
          can :manage, Course do |c|
            can? :manage, c.environment
          end
          can :read, Course do |c|
            c.user_course_associations.
              exists?(:user_id => user, :role => @non_admin_roles)
          end
        end
      end
    end

  end
end
