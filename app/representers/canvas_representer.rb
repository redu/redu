module CanvasRepresenter
  include Roar::Representer::JSON
  include LectureRepresenter

  property :lectureable_client_application, :from => :client_application,
    :extend => ClientApplicationRepresenter
  property :lecturable_current_url, :from => :current_url
  property :type

  def type
    'Canvas'
  end

  def lecturable_current_url
    self.lectureable.current_url
  end

  def lectureable_client_application
    self.lectureable.client_application
  end
end
