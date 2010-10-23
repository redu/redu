class InteractiveClass < ActiveRecord::Base
  
  # VALIDATIONS
  validates_length_of :lessons, :allow_nil => false, :within => 1..10, :too_long => "A aula contém {{count}} tópicos. O máximo de tópicos permitido é 50", :too_short => ": Uma aula deve conter ao menos um tópico."

  has_many :lessons, :order => 'position ASC', :dependent => :destroy#, :as => :lesson
  has_one :course, :as => :courseable

  accepts_nested_attributes_for :lessons, :allow_destroy => true

end
