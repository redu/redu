require 'representable/json/collection'

module InstantSearch
  module CollectionRepresenter
    include Representable::JSON::Collection

    def self.extend_object(obj)
      if instance = obj.first
        self.representation_wrap = instance.class.name.pluralize.downcase
      end
      super
    end

    items :class => ActiveRecord::Base, :extend => Proc.new { |model|
      InstantSearch.const_get(model.class.to_s + "Representer")
    }
  end
end
