module StatusRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :text
  property :created_at
  property :action
  property :type

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
end
