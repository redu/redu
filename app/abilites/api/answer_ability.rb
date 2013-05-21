# -*- encoding : utf-8 -*-
module Api
  module AnswerAbility
    extend ActiveSupport::Concern

    def answer_abilities(user)
      if user
        can :manage, Answer, :user_id => user.id
        can(:manage, Answer) { |answer| can? :manage, answer.in_response_to }
        can(:read, Answer) { |answer| can? :read, answer.in_response_to }
      end
    end
  end
end
