module Api
  module SubjectAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def subject_abilities(user)
        alias_action :create, :update, :destroy, :to => :manage
        @member ||= Role[:member]

        if user
          can :read, Subject do |s|
            if !s.visible && s.enrollments.exists?(:user_id => user,
                                                   :role => @member)
            else
              can? :read, s.space
            end
          end

          can :manage, Subject do |s|
            can? :manage, s.space
          end
        end
      end
    end
  end
end
