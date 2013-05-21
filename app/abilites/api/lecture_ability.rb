# -*- encoding : utf-8 -*-
module Api
  module LectureAbility
    extend ActiveSupport::Concern

    def lecture_abilities(user)
      if user
        can :read, Lecture do |lecture|
          can? :read, lecture.subject
        end
        can :manage, Lecture do |lecture|
          can? :manage, lecture.subject
        end
      end
    end
  end
end
