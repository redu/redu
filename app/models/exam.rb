class Exam < ActiveRecord::Base
 
  acts_as_taggable
  acts_as_commentable
  
  # associations
  has_many :question_exam_association#, :dependent => :destroy
  has_many :questions, :through => :question_exam_association, :include => :alternatives, :order => :position
  belongs_to :owner , :class_name => "User" , :foreign_key => "author_id"
  
  has_many :exam_users#, :dependent => :destroy
  has_many :user_history, :through => :exam_users, :source => :user

  # :counter_cache => true para ter uma coluna que conta o numero
  
  #validations
  validates_length_of :name, :within => 6..20, :too_long => "Por favor escolha um título menor que 20 caracteres", :too_short => "Por favor escolha um título maior que 6 caracteres"
  #validates_associated :questions 
  validates_length_of :questions, :allow_nil => false, :within => 2..100, :too_long => "O exame contém {{count}} questões. O máximo de questões permitido é 100", :too_short => "Um exame deve conter ao menos uma questão"

  has_and_belongs_to_many :resources
  
  named_scope :published, :conditions => ['published = ?', true], :include => :owner
  #named_scope :unpublished, :include => :owner
  
   cattr_reader :per_page
   @@per_page = 50

end
