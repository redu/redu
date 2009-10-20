class Question < ActiveRecord::Base
  
  #has_attachment prepare_options_for_attachment_fu(AppConfig.question['attachment_fu_options'])
  #validates_as_attachment
  
  belongs_to  :image#, :class_name => "Photo", :foreign_key => "image_id"

  
  has_many :alternatives
  
  has_many :question_exam_association
  has_many :exams, :through => :question_exam_association
  
  belongs_to :answer , :class_name => "Alternative", :foreign_key => "answer_id"
  
end
