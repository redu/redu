class Course < ActiveRecord::Base

  # PLUGINS
  acts_as_commentable
  ajaxful_rateable :stars => 5#, :dimensions => [:speed, :beauty, :price]
 
  
  # ASSOCIATIONS
  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :resources
  has_many :acess_key
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  
  # VALIDATIONS
  validates_presence_of :name
  
end
