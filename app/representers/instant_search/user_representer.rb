module InstantSearch
  module UserRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :display_name, :from => :name
    link :self_public do
      url_for(self)
    end
  end
end
