class Question < ActiveRecord::Base
  # associations
  has_many :alternatives, :dependent => :destroy
  has_many :question_exam_association
  has_many :exams, :through => :question_exam_association
  belongs_to :answer , :class_name => "Alternative", :foreign_key => "answer_id"
  belongs_to :author , :class_name => "User" , :foreign_key => "author_id"
  
  belongs_to :category, :class_name => "Skill", :foreign_key => "skill_id"
  
  #validations  
  validates_presence_of :statement
  validates_length_of :statement, :minimum => 6, :too_short => "Por favor escolha um enunciado maior que 6 caracteres"
  
  validates_associated :alternatives 
  validates_length_of :alternatives, :allow_nil => false, :within => 1..7#, :too_long => "O exame contém {{count}} questões. O máximo de questões permitido é 100", :too_short => "Um exame deve conter ao menos uma questão"


  named_scope :public, :conditions => ['public = ?', true]

  
end
