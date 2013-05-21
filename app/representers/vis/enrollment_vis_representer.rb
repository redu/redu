# -*- encoding : utf-8 -*-
module Vis
  module EnrollmentVisRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :user_id
    property :subject_id
    property :space_id
    property :course_id
    property :created_at
    property :updated_at

    def space_id
      self.subject.space.id
    end

    def course_id
      self.subject.space.course.id
    end
  end
end
