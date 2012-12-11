require 'representable/json/collection'

module InstantSearch
  module CollectionRepresenter
    include Representable::JSON::Collection

    self.representation_wrap = :still_unknown_collection_name

    items :class => ActiveRecord::Base, :extend => InstantSearch::PolymorphicExtender
  end
end
