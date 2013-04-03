module StatusVisRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :type
  property :user_id
  property :lecture_id
  property :subject_id
  property :space_id
  property :course_id
  property :status_id
  property :statusable_id
  property :statusable_type
  property :in_response_to_id
  property :in_response_to_type
  property :created_at
  property :updated_at

  def status_id
    self.id
  end

  def lecture_id
    case self.statusable.class.to_s
    when "Lecture"
      self.statusable_id
    when "Activity", "Help"
      if self.statusable.statusable.class.to_s == "Lecture"
        self.statusable.statusable_id
      else
        nil
      end
    else
      nil
    end
  end

  def subject_id
    case self.statusable.class.to_s
    when "Lecture"
      self.statusable.subject.id
    when "Activity", "Help"
      if self.statusable.statusable.class.to_s == "Lecture"
        self.statusable.statusable.subject.id
      else
        nil
      end
    else
      nil
    end
  end

  def space_id
    case self.statusable.class.to_s
    when "Lecture"
      self.statusable.subject.space.id
    when "Space"
      self.statusable.id
    when "Activity", "Help"
      statusable = self.statusable
      case statusable.statusable.class.to_s
      when "Lecture"
        statusable.statusable.subject.space.id
      when "Space"
        statusable.statusable_id
      end
    else
      nil
    end
  end

  def course_id
    case self.statusable.class.to_s
    when "Lecture"
      self.statusable.subject.space.course.id
    when "Space"
      self.statusable.course.id
    when "Activity", "Help"
      statusable = self.statusable
      case statusable.statusable.class.to_s
      when "Lecture"
        statusable.statusable.subject.space.course.id
      when "Space"
        statusable.statusable.course.id
      end
    else
      nil
    end
  end
end
