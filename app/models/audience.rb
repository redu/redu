class Audience < ActiveRecord::Base

	# ASSOCIATIONS
  has_and_belongs_to_many :spaces

end
