module SocialNetworkRepresenter
  include Roar::Representer::JSON

  property :name
  property :url, :from => :profile
end
