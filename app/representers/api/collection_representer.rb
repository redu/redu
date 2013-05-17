require 'representable/json/collection'

module CollectionRepresenter
  include Api::RepresenterInflector
  include Representable::JSON::Collection

  items :extend => Proc.new { |resource, options|
    if representer = representer_for_resource(resource)
      representer
    else
      raise RuntimeError.new("No representer found (#{representer_name(resource)})")
    end
  }
end
