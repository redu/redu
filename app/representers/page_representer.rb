module PageRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include LectureRepresenter

  property :content
  property :raw
  property :mimetype

  def mimetype
    'text/html'
  end

  def content
    self.lectureable.body
  end

  def raw
    ActionView::Base.full_sanitizer.sanitize(self.lectureable.body)
  end
end
