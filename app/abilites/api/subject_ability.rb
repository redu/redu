module Api
  module SubjectAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def subject_abilities(user)
        alias_action :destroy, :to => :manage
        @member ||= Role[:member]

        if user
          can :read, Subject do |s|
            if not(s.visible) and s.space.user_space_associations.approved.
                  exists?(:user_id => user, :role => @member)
            else
              can? :read, s.space
            end
          end

          can :create, Subject do |s|
            can? :create, s.space
          end

          can :manage, Subject do |s|
            can? :manage, s.space
          end
        end
      end
    end
  end
end
