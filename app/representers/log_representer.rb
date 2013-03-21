module LogRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  property :action_text, :from => :text
  property :logeable_type

  link :logeable do
    polymorphic_url([:api, self.logeable])
  end
end
