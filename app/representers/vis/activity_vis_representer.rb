module Vis
  module ActivityVisRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia
    include StatusVisRepresenter

    def lecture_id
      if self.statusable.class.to_s == "Lecture"
        self.statusable_id
      else
        nil
      end
    end

    def subject_id
      case self.statusable.class.to_s
      when "Lecture"
        self.statusable.subject.id
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
      else
        nil
      end
    end

  end
end
