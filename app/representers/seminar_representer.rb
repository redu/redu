module SeminarRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include LectureRepresenter

  property :mimetype

  def type
    'Media'
  end

  def mimetype
    if self.lectureable.external?
      'video/x-youtube'
    else
      self.lectureable.original_content_type
    end
  end

  link :raw do
    if self.lectureable.external?
      self.lectureable.external_resource_url
    else
      self.lectureable.original.url
    end
  end
end

