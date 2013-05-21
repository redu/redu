# -*- encoding : utf-8 -*-
require 'representable/json/collection'

module Api
  module CollectionRepresenter
    include Api::RepresenterInflector
    include Representable::JSON::Collection

    items :extend => Proc.new { |resource, _| representer_for_resource(resource) }
  end
end
