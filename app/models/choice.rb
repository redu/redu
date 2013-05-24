# -*- encoding : utf-8 -*-
class Choice < ActiveRecord::Base
  belongs_to :user
  belongs_to :alternative
  belongs_to :question

  scope :correct, lambda { where(correct: true) }

  validates_uniqueness_of :user_id, scope: :question_id
end
