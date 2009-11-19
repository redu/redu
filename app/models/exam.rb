class Exam < ActiveRecord::Base
 
 acts_as_commentable
 ajaxful_rateable :stars => 5
  
  # associations
  has_many :question_exam_association#, :dependent => :destroy
  has_many :questions, :through => :question_exam_association, :include => :alternatives, :order => :position
  belongs_to :owner , :class_name => "User" , :foreign_key => "author_id"

  # :counter_cache => true para ter uma coluna que conta o numero
  
  #validations
  validates_length_of :name, :within => 6..20, :too_long => "Por favor escolha um título menor que 20 caracteres", :too_short => "Por favor escolha um título maior que 6 caracteres"
  #validates_associated :questions 
  validates_length_of :questions, :allow_nil => false, :within => 1..100, :too_long => "O exame contém {{count}} questões. O máximo de questões permitido é 100", :too_short => "Um exame deve conter ao menos uma questão"

  has_and_belongs_to_many :resources
  
    named_scope :published, :conditions => ['published = ?', true]
  named_scope :unpublished, :conditions => ['published = ?', false]
  

end
