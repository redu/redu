class Subject < ActiveRecord::Base

  # Associations
  has_many :lecture_subjects, :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  belongs_to :user
  belongs_to :space

  # METODOS DO WIZARD
  # accessors 
  attr_writer :current_step

  # Validations
  validates_presence_of :title, :if => lambda {|s| s.current_step == "subject"}
  validates_presence_of :description, :if => lambda {|s| s.current_step == "subject"}

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[subject lecture publication]
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

  def create_lecture_subject_type_lecture aulas, subject_id, current_user

    aulas.each do |aula|
      lecture = current_user.lectures.find(aula) #find the lecture by id
      clone_lecture = lecture.clone #clone it
      clone_lecture.is_clone = true
      clone_lecture.save#and save it
      cs = LectureSubject.new
      cs.subject_id = subject_id
      cs.lectureable_id = clone_lecture.id
      cs.lectureable_type = "Lecture"
      cs.save
    end

  end

  def create_lecture_subject_type_exam exams, subject_id

    exams.each do |exam_id|
      cs = LectureSubject.new
      cs.subject_id = subject_id
      cs.lectureable_id = exam_id
      cs.lectureable_type = "Exam"
      cs.save
    end

  end
end
