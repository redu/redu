module SpaceRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name
  property :description
  property :created_at


  link :self do
    api_space_url(self)
  end

  link :course do
    api_course_url(self.course)
  end

  link :environment do
    api_environment_url(self.course.environment)
  end

  link :users do
    api_space_users_url(self)
  end
end
