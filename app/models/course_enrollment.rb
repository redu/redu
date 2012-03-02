class CourseEnrollment < ActiveRecord::Base
  include AASM
  belongs_to :course
end
