module InstantSearch
  module EnvironmentRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    link :self_public do
      url_for(self)
    end
  end
end
