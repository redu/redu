module Api
  module SubjectAbility
    extend ActiveSupport::Concern
    module InstanceMethods
      def subject_abilities(user)
        administrative_roles = [Role[:teacher],
                                Role[:course_admin],
                                Role[:environment_admin]]

        if user
          can :read, Subject do |s|
            s.enrollments.exists?(:user_id => user)
          end

          can :manage, Subject do |s|
            s.enrollments.exists?(:user_id => user, :role => administrative_roles)
          end          
        end
      end
    end
  end
end
