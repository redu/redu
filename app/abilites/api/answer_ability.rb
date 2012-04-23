module Api
  module AnswerAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def answer_abilities(user)
        if user
          can :read, Answer do |s|
            can? :read, s.in_response_to
          end
          can :create, Answer do |s|
            can? :read, s.in_response_to
          end
          can :destroy, Answer do |s|
            can? :manage, s.in_response_to
          end
        end

      end
    end
  end
end
