module LogRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  property :action_text

  link :logeable do
    api_user_url(self.logeable)
  end
end
