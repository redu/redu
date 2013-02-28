module SpaceRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :name
  property :description
  property :created_at
  property :updated_at

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

  link :subjects do
    api_space_subjects_url(self)
  end

  link :statuses do
     api_space_statuses_url(self)
  end

  link :timeline do
    timeline_api_space_statuses_url(self)
  end

  link :folders do
    api_space_folders_url(self)
  end

  link :canvas do
    api_space_canvas_index_url(self)
  end
end
