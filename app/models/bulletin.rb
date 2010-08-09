class Bulletin < ActiveRecord::Base

	#PLUGINS
	#	acts_as_commentable
	acts_as_taggable
  acts_as_voteable	
  ajaxful_rateable :stars => 5

	#ASSOCIATIONS
	belongs_to :school

	#VALIDATIONS
	validate_of_presence_of :title, :description
	
end
