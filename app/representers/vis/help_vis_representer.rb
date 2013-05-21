# -*- encoding : utf-8 -*-
module Vis
  module HelpVisRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    include StatusVisRepresenter

    def lecture_id
      self.statusable_id
    end

    def subject_id
      self.statusable.subject.id
    end

    def space_id
      self.statusable.subject.space.id
    end

    def course_id
      self.statusable.subject.space.course.id
    end
  end
end
