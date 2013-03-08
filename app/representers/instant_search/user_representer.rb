module InstantSearch
  module UserRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :display_name, :from => :name
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
      "profile"
    end

    def legend
      # Funções dos cargos atuais.
      self.experiences.actual_jobs.map{ |exp| exp.title.strip }.join(", ")
    end
  end
end
