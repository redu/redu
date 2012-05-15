module Api
  module LectureAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def lecture_abilities(user)
        alias_action :create, :destroy, :to => :manage

        if user
          can :read, Lecture do |l|
            can? :read, l.subject
          end

          can :manage, Lecture do |l|
            can? :manage, l.subject
          end
        end
      end
    end
  end
end
