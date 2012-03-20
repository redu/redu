module AnswerRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter


  link :in_response_to do
      api_status_url(self)
  end
end
