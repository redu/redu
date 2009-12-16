class Course < ActiveRecord::Base

  # VALIDATIONS
  validates_presence_of :name
  
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
  has_many :course_prices
  has_many :acquisitions
  
  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :description #new column created at december, 12
  
end
