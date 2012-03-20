module LogRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter


  link :logeable do
    api_status_url(self)
  end
end
