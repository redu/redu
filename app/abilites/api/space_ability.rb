module Api
  module SpaceAbility
    extend ActiveSupport::Concern

    def space_abilities(user)
      @teacher_role ||= Role[:teacher]
      @administrative_roles = [Role[:teacher], Role[:environment_admin]]

      if user
        can(:create, Space) { |s| can? :manage, s.course }
        can :create, Space  do |s|
          s.course.user_course_associations.approved.
            exists?(:user_id => user, :role => @teacher_role)
        end
        can :read, Space do |s|
          s.user_space_associations.exists?(:user_id => user)
        end
        can :manage, Space do |s|
          s.user_space_associations.exists?(:user_id => user,
                                            :role => @administrative_roles)
        end
      end
    end
  end
end
