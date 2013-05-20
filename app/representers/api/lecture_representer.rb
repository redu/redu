# -*- encoding : utf-8 -*-
module Api
  module LectureRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    property :position
    property :view_count
    property :type
    property :rate_average, :from => :rating
    property :created_at
    property :updated_at

    def type
      self.lectureable_type.to_s
    end

    link :self do
      api_lecture_url(self)
    end

    link :self_link do
      space_subject_lecture_url(self.subject.space, self.subject, self)
    end

    link :subject do
      api_subject_url(self.subject)
    end

    link :space do
      api_space_url(self.subject.space)
    end

    link :course do
      api_course_url(self.subject.space.course)
    end

    link :environment do
      api_environment_url(self.subject.space.course.environment)
    end

    link :next_lecture do
      api_lecture_url(self.next_item) unless self.last_item?
    end

    link :previous_lecture do
      api_lecture_url(self.previous_item) unless self.first_item?
    end
  end
end
