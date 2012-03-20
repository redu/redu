module ActivityRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  property :text

  link :answers do
    api_status_url(self)
  end
end
