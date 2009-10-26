class Exam < ActiveRecord::Base
  
  has_many :question_exam_association#, :dependent => :destroy
  has_many :questions, :through => :question_exam_association, :include => :alternatives, :order => :position
 
  
  belongs_to :author , :class_name => "User" , :foreign_key => "author_id"

  # :counter_cache => true para ter uma coluna que conta o numero


end
