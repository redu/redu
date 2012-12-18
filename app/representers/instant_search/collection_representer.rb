require 'representable/json/collection'

module InstantSearch
  module CollectionRepresenter
    include Representable::JSON::Collection

    def self.extend_object(obj)
      if obj.first # Assume-se que o obj em questão é um array não vazio
        self.representation_wrap = obj.first.class.name.pluralize.downcase
      end
      super
    end

    items :class => ActiveRecord::Base, :extend => InstantSearch::PolymorphicExtender
  end
end
