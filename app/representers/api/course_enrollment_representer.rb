module Api
  module CourseEnrollmentRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :state
    property :id
    property :email #works only for UCI
    property :created_at
    property :updated_at
    property :token
    property :computed_role, :from => :role, :render_nil => true

    def computed_role
      self.role
    end

    link :self do
      api_enrollment_url(self)
    end

    link :course do
      api_course_url(self.course)
    end

    link :environment do
      api_course_url(self.course.environment)
    end

    link :user do
      api_user_url(self.user) if self.user
    end
  end
end
