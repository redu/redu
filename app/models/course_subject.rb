class CourseSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :courseable, :polymorphic => true
  
  def destroy #destroi a aula clone associada a esse course_subject
    unless self.courseable.nil?
      
       self.courseable.courseable.destroy unless self.courseable.class.to_s.eql?("Exam") #remove o aula em si, um page, seminar or interactive_class
       self.courseable.destroy 
    end
    super
  end
end
