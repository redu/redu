module SeminarRepresenter
  include Roar::Representer::Feature::Hypermedia
  include Roar::Representer::JSON

  property :state
  property :url

  def url
    if external?
      "http://youtube.com/watch?v=#{self.external_resource}"
    else
      self.media.url
    end
  end

  def state
    if external?
      "converted"
    else
      super
    end
  end
end
