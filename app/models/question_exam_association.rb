class QuestionExamAssociation < ActiveRecord::Base
  
  belongs_to :question, :dependent => :destroy
  belongs_to :exam, :dependent => :destroy
  
end
