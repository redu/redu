require 'representable/json/collection'

module StatusesRepresenter
  include Api::RepresenterInflector
  include Representable::JSON::Collection

  items :extend => Proc.new { |status, opts|
    representer_for_resource(status) || StatusRepresenter
  }
end

