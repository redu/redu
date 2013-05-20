# -*- encoding : utf-8 -*-
module Api
  module LogRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia
    include StatusRepresenter

    include Api::BreadcrumbLinks

    property :action_text, :from => :text
    property :computed_logeable_type, :from => :logeable_type

    def computed_logeable_type
      return 'Enrollment' if logeable.is_a? CourseEnrollment
      self.logeable_type
    end

    link :logeable do
      if logeable.is_a? CourseEnrollment
        api_enrollment_url(logeable.becomes(CourseEnrollment))
      elsif %w(Lecture Course Subject User Friendship Space).include? self.logeable_type
        polymorphic_url([:api, self.logeable])
      end
    end
  end
end
