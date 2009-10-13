class Alternative < ActiveRecord::Base
  
  belongs_to :question, :autosave => true
  validates_presence_of(:statement)
  
  has_one :question, :foreign_key => "answer_id"
  
end
