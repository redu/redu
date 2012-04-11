module LogRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
#  include StatusRepresenter

  property :id
  property :created_at
  property :text
  property :type

  link :self do
    api_status_url self
  end

  link :statusable do
    polymorphic_url([:api, self.statusable])
  end

  link :user do
    api_user_url(self.user)
  end

  link :logeable do
    api_user_url(self.logeable)
  end
end
