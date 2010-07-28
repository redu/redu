class InteractiveClass < ActiveRecord::Base
  
  has_many :lessons, :order => 'position ASC', :dependent => :destroy#, :as => :lesson
 #belongs_to :course
    has_one :course, :as => :courseable
    
  has_many :resources, :class_name => "CourseResource", :as => :attachable,:dependent => :destroy
  
 # before_create :remove_others # TODO so fazer essa consulta se usuario tiver voltado no wizard e o sistema criado um outra instancia
  
  accepts_nested_attributes_for :lessons, :allow_destroy => true

  accepts_nested_attributes_for :resources, 
    :reject_if => lambda { |a| a[:media].blank? },
    :allow_destroy => true
    
 # validates_length_of :lessons, :allow_nil => false, :within => 5..50, :too_long => "A aula contém {{count}} tópicos. O máximo de tópicos permitido é 50", :too_short => ": Uma aula deve conter ao menos um tópico."
 
  
  
  
  
#  def remove_others
#    InteractiveClass.delete_all(:course_id => self.course.id)
#  end
  
  
end