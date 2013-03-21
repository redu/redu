module LogRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  property :action_text, :from => :text
  property :computed_logeable_type, :from => :logeable_type

  def computed_logeable_type
    return 'Enrollment' if logeable.is_a? CourseEnrollment
    self.logeable_type
  end

  link :logeable do
    if logeable.is_a? CourseEnrollment
      api_enrollment_url(logeable.becomes(CourseEnrollment))
    else
      polymorphic_url([:api, self.logeable])
    end
  end
end
