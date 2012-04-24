module Api
  module LectureAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def lecture_abilities(user)
        if user
          can :read, Lecture do |l|
            can? :read, l.subject
          end
        end
      end
    end
  end
end
