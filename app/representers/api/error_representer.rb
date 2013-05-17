module Api
  module ErrorRepresenter
    include Roar::Representer::JSON

    property :error

  end
end
