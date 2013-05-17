module CourseRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :name
  property :description
  property :created_at
  property :updated_at
  property :workload
  property :path

  link :self do
    api_course_url(self)
  end

  link :spaces do
    api_course_spaces_url(self)
  end

  link :environment do
    api_environment_url(self.environment)
  end

  link :enrollments do
    api_course_enrollments_url(self)
  end

end
