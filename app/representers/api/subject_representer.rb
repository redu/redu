# -*- encoding : utf-8 -*-
module Api
  module SubjectRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    property :description
    property :user_grades, getter: lambda { |args| if enrollment = args[:user].get_association_with(self) then enrollment.grade.to_i else nil end }
    property :created_at
    property :updated_at

    link :self do
      api_subject_url(self)
    end

    link :lectures do
      api_subject_lectures_url(self)
    end

    link :space do
      api_course_url(self.space)
    end

    link :course do
      api_course_url(self.space.course)
    end

    link :environment do
      api_environment_url(self.space.course.environment)
    end

  end
end
