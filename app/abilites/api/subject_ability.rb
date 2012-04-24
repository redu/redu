module Api
  module SubjectAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def subject_abilities(user)
        if user
          can :read, Subject do |s|
            can? :read, s.space
          end
        end
      end
    end
  end
end
