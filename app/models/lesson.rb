class Lesson < ActiveRecord::Base

  validates_presence_of :title
  
  belongs_to :interactive_class
  belongs_to :lesson, :polymorphic => true, :dependent => :destroy

  accepts_nested_attributes_for :lesson, :allow_destroy => true

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
    when 'ExternalObject'
      params.delete(:lesson_type)
      self.lesson = ExternalObject.new(params)
    end
  end

end
