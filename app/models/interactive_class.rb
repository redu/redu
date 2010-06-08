class InteractiveClass < ActiveRecord::Base
  
  has_many :lessons, :order => 'position ASC'
  belongs_to :course
  
  
   accepts_nested_attributes_for :lessons
   
   before_create :remove_others # TODO so fazer essa consulta se usuario tiver voltado no wizard e o sistema criado um outra instancia
end


def remove_others
  InteractiveClass.delete_all(:course_id => self.course.id)
end
