class CourseResourceAssociation < ActiveRecord::Base
	belongs_to :course
	belongs_to :resource
end
