class Subject < ActiveRecord::Base

  #validations
  validates_presence_of :title, :if => lambda {|s| s.current_step == "subject"}
  validates_presence_of :description, :if => lambda {|s| s.current_step == "subject"}

  #associations
  has_many :course_subjects, :dependent => :destroy
  has_many :enrollments, :as => :enrollmentable, :dependent => :destroy
  belongs_to :user
  belongs_to :school


   # METODOS DO WIZARD
  attr_writer :current_step


  def current_step
    @current_step || steps.first
  end

  def steps
    %w[subject course publication]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

   def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

   def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end


  
  def create_course_subject_type_course aulas, subject_id
    
    aulas.each do |aula|
     cs = CourseSubject.new
     cs.subject_id = subject_id
     cs.courseable_id = aula
     cs.courseable_type = "Course"
     cs.save
    end

  end

  def create_course_subject_type_exam exams, subject_id

    exams.each do |exam_id|
     cs = CourseSubject.new
     cs.subject_id = subject_id
     cs.courseable_id = exam_id
     cs.courseable_type = "Exam"
     cs.save
    end

  end

end
