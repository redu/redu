module InstantSearch
  module SpaceRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    link :slef_public do
      url_for(self)
    end
    property :thumbnail
    property :type
    property :legend

    def thumbnail
      self.course.environment.avatar.url(:thumb_32)
    end

    def type
      "environment"
    end

    def legend
      "Disciplina — #{self.course.environment.name}"
    end
  end
end
