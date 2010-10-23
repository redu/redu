class Alternative < ActiveRecord::Base
  # associations
  belongs_to :question
  has_one :question, :foreign_key => "answer_id"

  #validations
  validates_presence_of :statement
end
