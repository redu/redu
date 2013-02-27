module CanvasRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include LectureRepresenter

  property :mimetype
  property :current_url
  property :lectureable_container_type, :from => :container_type

  def lectureable_container_type
    self.lectureable.container_type
  end

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

  link :container do
    api_subject_url(self.subject)
  end
end
