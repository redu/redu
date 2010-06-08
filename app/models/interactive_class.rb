class InteractiveClass < ActiveRecord::Base
  
  has_many :lessons, :order => 'position ASC'
  belongs_to :course
  
  has_many :resources, :class_name => "CourseResource", :as => :attachable
  
  before_create :remove_others # TODO so fazer essa consulta se usuario tiver voltado no wizard e o sistema criado um outra instancia
  
  accepts_nested_attributes_for :lessons
  accepts_nested_attributes_for :resources, 
    :reject_if => lambda { |a| a[:media].blank? },
    :allow_destroy => true
  
  
  def remove_others
    InteractiveClass.delete_all(:course_id => self.course.id)
  end
  
end