module InstantSearch
  module CourseRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    link :self_public do
      environment_course_url(self.environment, self)
    end
  end
end
