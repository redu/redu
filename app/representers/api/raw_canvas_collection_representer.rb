require 'representable/json/collection'

module RawCanvasCollectionRepresenter
  include Representable::JSON::Collection

  items :extend => RawCanvasRepresenter
end

