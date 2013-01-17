module DocumentRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :mimetype

  link :raw do
    self.attachment.url
  end

  link :scribd do
    self.scribd_url
  end

  def mimetype
    self.attachment_content_type
  end
end
