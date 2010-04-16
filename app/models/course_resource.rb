class CourseResource < ActiveRecord::Base
	has_attached_file :media

	validates_presence_of :name
	validates_attachment_presence :media
	validates_attachment_size :media,
		:less_than => 50.megabytes
end
