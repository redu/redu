class Course < ActiveRecord::Base

  # PLUGINS
  acts_as_commentable
  ajaxful_rateable :stars => 5#, :dimensions => [:speed, :beauty, :price]
  validation_group :step1, :fields=>[:name, :description, :owner]
  validation_group :step2, :fields=>[:courses_resources]
 
  
  # ASSOCIATIONS
  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :resources
  has_many :acess_key
  has_many :course_resource_association
	has_many :resources, :through => :course_resource_association
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  
  # VALIDATIONS
  #validates_presence_of :name
  
end
