module Api
  module CourseEnrollmentAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def course_enrollment_abilities(user)
        if user
          can(:manage, CourseEnrollment) { |e| can?(:manage, e.course) }
          can :destroy, CourseEnrollment, :user_id => user.id
        end
      end
    end

  end
end
