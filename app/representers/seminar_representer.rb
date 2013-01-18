module SeminarRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include LectureRepresenter

  property :mimetype
  property :type

  def type
    'Media'
  end

  def mimetype
    'video/x-youtube'
  end

  link :raw do
    self.lectureable.external_resource_url
  end
end

