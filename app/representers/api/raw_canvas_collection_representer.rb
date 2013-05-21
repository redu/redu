# -*- encoding : utf-8 -*-
require 'representable/json/collection'

module Api
  module RawCanvasCollectionRepresenter
    include Representable::JSON::Collection

    items :extend => RawCanvasRepresenter
  end
end

