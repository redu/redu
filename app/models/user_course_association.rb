class UserCourseAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  has_enumerated :role
end
