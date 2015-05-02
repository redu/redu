class ArAnswer < ActiveRecord::Base
  belongs_to :user
  belongs_to :ar_question
  attr_accessible :rate, :texto

  validates_uniqueness_of :user_id, scope: :ar_question_id


end
