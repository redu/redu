module AnswerRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia


  link :in_response_to do
      api_status_url(self)
  end
end
