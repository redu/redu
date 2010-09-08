class Alternative < ActiveRecord::Base
  # associations
  belongs_to :question#, :autosave => true
  has_one :question, :foreign_key => "answer_id"
  
  #validations
  validates_presence_of :statement 
  
#  after_save :test
#  
#  
#  def test
#    
#    puts 'alternative saved id: '+id.to_s
#    
#  end
  
  

end
