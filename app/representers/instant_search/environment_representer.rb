module InstantSearch
  module EnvironmentRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    link :self_public do
      url_for(self)
    end
    property :thumbnail
    property :type
    property :legend

    def thumbnail
      self.avatar.url(:thumb_32)
    end

    def type
      "environment"
    end

    def legend
      "Ambiente de Aprendizagem"
    end
  end
end
