class SubjectFile < ActiveRecord::Base

  belongs_to :subject

  has_attached_file :attachment

end
