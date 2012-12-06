module Untied
  module EnvironmentRepresenter
    # Utilizado para serializar modelo de User enviado pelo Untied
    include Roar::Representer::JSON
    include Untied::HasAttachmentRepresenter

    self.representation_wrap = true

    property :id
    property :name
    property :user_id
  end
end

