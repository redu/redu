module Api
  module DocumentRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia
    include LectureRepresenter

    property :mimetype

    def mimetype
      self.lectureable.attachment_content_type
    end

    link :raw do
      self.lectureable.attachment.url
    end

    link :scribd do
      self.lectureable.scribd_url
    end
  end
end
