class Question < ActiveRecord::Base
  #has_many :QuestionExamAssociation
  
  has_many :alternatives
  
  has_many :question_exam_association
  has_many :exams, :through => :question_exam_association
  
  belongs_to :answer , :class_name => "Alternative", :foreign_key => "answer_id"
  #validates_presence_of(:)
  
end
