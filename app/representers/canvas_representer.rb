module CanvasRepresenter
  include Roar::Representer::JSON

  property :client_application, :extend => ClientApplicationRepresenter
  property :current_url
end
