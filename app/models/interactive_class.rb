class InteractiveClass < ActiveRecord::Base
  
  has_many :lessons
  belongs_to :course
  
end
