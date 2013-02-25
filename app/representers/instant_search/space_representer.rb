module InstantSearch
  module SpaceRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    link :slef_public do
      url_for(self)
    end
  end
end
