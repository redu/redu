module Api
  module ClientApplicationRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    property :url
    property :support_url

  end
end
