module AnswerRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include StatusRepresenter

  link :statusable do
    if statusable.is_a?(Activity) || statusable.is_a?(Help)
      api_status_url(self.statusable)
    end
  end

  link :in_response_to do
    api_status_url(self.in_response_to)
  end
end
