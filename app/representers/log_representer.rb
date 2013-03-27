module LogRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  property :action_text, :from => :text
  property :logeable_type

  link :logeable do
    if %w(Lecture Course Subject User Friendship Space).include? self.logeable_type
      polymorphic_url([:api, self.logeable])
    end
  end
end
