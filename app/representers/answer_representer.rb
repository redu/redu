module AnswerRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  
  property :id
  property :created_at
  property :type
  property :text

  link :self do
    api_status_url self
    # polymorphic_url([:api, self])
  end

  link :statusable do
    if statusable.is_a?(User) || statusable.is_a?(Space)
      polymorphic_url([:api, self.statusable])
    end
  end

  link :user do
    api_user_url(self.user)
  end
  
  link :in_response_to do
    api_status_url(self)
  end
end
