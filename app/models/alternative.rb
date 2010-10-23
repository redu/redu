class Alternative < ActiveRecord::Base
  
	# ASSOCIATIONS
  belongs_to :question
  has_one :question, :foreign_key => "answer_id"

  # VALIDATIONS
  validates_presence_of :statement
end
