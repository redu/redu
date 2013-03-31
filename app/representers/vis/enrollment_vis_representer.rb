module EnrollmentVisRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  @@type = nil

  property :type
  property :user_id
  property :subject_id
  property :space_id
  property :course_id
  property :created_at
  property :updated_at

  def type
    @@type
  end

  def self.type=(type)
    @@type = type
  end

  def space_id
    self.subject.space.id
  end

  def course_id
    self.subject.space.course.id
  end
end
