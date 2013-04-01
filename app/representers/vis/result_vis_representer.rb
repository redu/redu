module ResultVisRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  @@type = nil

  property :type
  property :user_id
  property :lecture_id
  property :subject_id
  property :space_id
  property :course_id
  property :grade
  property :created_at
  property :updated_at

  def type
    @@type
  end

  def self.type=(type)
    @@type = type
  end

  def lecture_id
    self.exercise.lecture.id
  end

  def subject_id
    self.exercise.lecture.subject.id
  end

  def space_id
    self.exercise.lecture.subject.space.id
  end

  def course_id
    self.exercise.lecture.subject.space.course.id
  end
end
