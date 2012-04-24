module AnswerRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  link :statusable do
    if statusable == nil # FIXME em qual caso o statusable de um Answer é nil? Esse if é necessário?
      api_status_url(self.statusable)
    else
      api_status_url(self.in_response_to)
    end
  end

  link :in_response_to do
    api_status_url(self.in_response_to)
  end
end
