class CourseSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :courseable, :polymorphic => true
  
  def destroy #destroi a aula clone associada a esse course_subject
    self.courseable.destroy unless self.courseable.nil?
    super
  end
end
