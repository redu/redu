require 'representable/json/collection'
module CourseEnrollmentsRepresenter
  include Representable::JSON::Collection

  items :extend => CourseEnrollmentRepresenter
end
