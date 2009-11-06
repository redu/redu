class Profile < ActiveRecord::Base
  
  MALE    = 'M'
  FEMALE  = 'F'
  
  belongs_to :user
  
  validates_date :birthday, :before => 13.years.ago.to_date 
  
  

  
  
end
