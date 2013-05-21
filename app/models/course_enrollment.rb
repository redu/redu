# -*- encoding : utf-8 -*-
class CourseEnrollment < ActiveRecord::Base
  include AASM
  belongs_to :course
end
