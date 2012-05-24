module DocumentRepresenter
  include Roar::Representer::Feature::Hypermedia
  include Roar::Representer::JSON

  property :url

  def url
    self.attachment.url
  end
end
