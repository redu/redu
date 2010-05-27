class InteractiveClass < ActiveRecord::Base
  
  has_many :lessons
  belongs_to :course
  
  
   accepts_nested_attributes_for :lessons
end
