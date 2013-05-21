# -*- encoding : utf-8 -*-
module Api
  module RawCanvasRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :current_name, :from => :name
    property :current_url
    property :created_at
    property :updated_at
    property :container_type

    link(:raw) { current_url }

    link :self do
      api_canvas_url(self)
    end

    link :self_link do
      space_canvas_url(self.container, self)
    end

    link :container do
      api_space_url(self.container)
    end
  end
end

