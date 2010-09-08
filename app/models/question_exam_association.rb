class QuestionExamAssociation < ActiveRecord::Base
  
  belongs_to :question, :dependent => :destroy
  belongs_to :exam, :dependent => :destroy

  acts_as_list :scope => :exam



  #validates_uniqueness_of :question_id, :scope => :exam

end
