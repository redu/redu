class Lesson < ActiveRecord::Base
  
  belongs_to :interactive_class
 #acts_as_list :scope => :interactive_class #NAO USE 

 belongs_to :lesson, :polymorphic => true
 
 accepts_nested_attributes_for :lesson, :allow_destroy => true
 


#def attributes=(attributes = {})
#  self.lesson_type = attributes[:lesson_type]
#  super
#end

# Implement build_polymorph_model because it will not be generated automatically
#  def build_lesson(attributes = {})
#     puts attributes.to_s
#     if self.lesson
#    self.notifiable = self.lesson.classify.constantize.new(attributes)
#    end
#  end

def build_lesson(params)
    self.position = params[:position]
    params.delete(:position)
    case params[:lesson_type]  # importante manter nome lesson_tp e nao lesson_type
    when 'Page'
      params.delete(:lesson_type)
      self.lesson = Page.new(params)
    when 'Seminar'
      params.delete(:lesson_type)
      self.lesson = Seminar.new(params)
    end
  end

end
