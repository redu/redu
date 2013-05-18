require 'representable/json/collection'
module Api
  module CourseEnrollmentsRepresenter
    include Representable::JSON::Collection

    items :extend => CourseEnrollmentRepresenter
  end
end
