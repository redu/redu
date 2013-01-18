module SeminarRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :mimetype

  def mimetype
    'video/x-youtube'
  end

  link :raw do
    self.external_resource_url
  end
end

