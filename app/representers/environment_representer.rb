module EnvironmentRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name
  property :description
  property :created_at
  property :path
  property :initials

  link :self do
    api_environment_url(self)
  end

  link :courses do
    api_environment_courses_url(self)
  end
end
