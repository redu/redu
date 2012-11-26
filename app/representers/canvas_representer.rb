module CanvasRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :client_application, :extend => ClientApplicationRepresenter
end
