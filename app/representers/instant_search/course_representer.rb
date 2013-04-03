module InstantSearch
  module CourseRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    property :thumbnail
    property :type
    property :legend

    link :self_public do
      environment_course_url(self.environment, self)
    end

    def thumbnail
      self.environment.avatar.url(:thumb_32)
    end

    def type
      "environment"
    end

    def legend
      "Curso — #{self.environment.name}"
    end
  end
end
