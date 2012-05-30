module ActivityRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  link :answers do
    api_status_answers_url(self)
  end
end
