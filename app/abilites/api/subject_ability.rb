module Api
  module SubjectAbility
    extend ActiveSupport::Concern

    def subject_abilities(user)
      alias_action :destroy, :create, :to => :manage

      if user
        can :read, Subject do |s|
          can? :read, s.space
        end

        can :manage, Subject do |s|
          can? :manage, s.space
        end
      end
    end
  end
end
