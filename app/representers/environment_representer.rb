module EnvironmentRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  include Api::ThumbnailCollection

  property :name
  property :description
  property :created_at
  property :updated_at
  property :path
  property :initials
  property :id
  property :courses_count

  def courses_count
    self.courses.count
  end

  link :self do
    api_environment_url(self)
  end

  link :courses do
    api_environment_courses_url(self)
  end

  link :user do
    api_user_url(self.owner)
  end
end
