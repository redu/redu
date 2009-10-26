class QuestionExamAssociation < ActiveRecord::Base
  
  belongs_to :question, :dependent => :destroy
  belongs_to :exam, :dependent => :destroy

  acts_as_list :scope => :exam


=begin
   before_create :update_position
  
  def update_position
    self.question.position
  end
=end  
end
