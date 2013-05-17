module Api
  module TagRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :name
  end
end
