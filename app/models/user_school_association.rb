class UserSchoolAssociation < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :school
  
  belongs_to :access_key
  has_enumerated :role 
  
end
