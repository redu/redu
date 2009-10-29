class Exam < ActiveRecord::Base
  # associations
  has_many :question_exam_association#, :dependent => :destroy
  has_many :questions, :through => :question_exam_association, :include => :alternatives, :order => :position
  belongs_to :author , :class_name => "User" , :foreign_key => "author_id"

  # :counter_cache => true para ter uma coluna que conta o numero
  
  #validations
  validates_length_of :title, :within => 6..20, :too_long => "Por favor escolha um título menor que 20 caracteres", :too_short => "Por favor escolha um título maior que 6 caracteres"
  validates_associated :questions 
  validates_length_of :questions, :allow_nil => false, :within => 1..100, :too_long => "O exame contém {{count}} questões. O máximo de questões permitido é 100", :too_short => "Um exame deve conter ao menos uma questão"


end
