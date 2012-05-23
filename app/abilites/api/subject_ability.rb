module Api
  module SubjectAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def subject_abilities(user)
        alias_action :create, :update, :destroy, :to => :manage
        @member ||= Role[:member]

        if user
          can :read, Subject do |s|
            can? :read, s.space if not not_visible_and_member(s, user)
          end

          can :manage, Subject do |s|
            can? :manage, s.space
          end
        end
      end
    end

    protected

    def not_visible_and_member(subject, user_current)
      true if !subject.visible && subject.enrollments.
                             exists?(:user_id => user_current, :role => @member)
    end

  end
end
