class CourseResource < ActiveRecord::Base
	has_attached_file :attachment
  belongs_to :attachable, :polymorphic => true

	validates_presence_of :attachment
	validates_attachment_presence :attachment
	validates_attachment_size :attachment,
		:less_than => 50.megabytes
    
    
    
end
