module Vis
  module AnswerVisRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia
    include StatusVisRepresenter

    def lecture_id
      if self.statusable.statusable.class.to_s == "Lecture"
        self.statusable.statusable_id
      else
        nil
      end
    end

    def subject_id
      if self.statusable.statusable.class.to_s == "Lecture"
        self.statusable.statusable.subject.id
      else
        nil
      end
    end

    def space_id
      statusable = self.statusable
      case statusable.statusable.class.to_s
      when "Lecture"
        statusable.statusable.subject.space.id
      when "Space"
        statusable.statusable_id
      else
        nil
      end
    end

    def course_id
      statusable = self.statusable
      case statusable.statusable.class.to_s
      when "Lecture"
        statusable.statusable.subject.space.course.id
      when "Space"
        statusable.statusable.course.id
      else
        nil
      end
    end
  end
end

