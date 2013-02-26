module CanvasRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include LectureRepresenter

  property :type
  property :mimetype
  property :current_url

  def type
    'Canvas'
  end

  def mimetype
    "application/x-canvas"
  end

  def current_url
    self.lectureable.current_url
  end

  link :raw do
    self.lectureable.current_url
  end
end
