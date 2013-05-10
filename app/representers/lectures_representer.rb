require 'representable/json/collection'

module LecturesRepresenter
  include Api::RepresenterInflector
  include Representable::JSON::Collection

  items :extend => Proc.new { |lecture, options|
    representer_for_resource(lecture.lectureable) || LectureRepresenter
  }
end
