module InstantSearch
  module UserRepresenter
    include Roar::Representer::JSON

    property :id
    property :display_name, :from => :name
  end
end
