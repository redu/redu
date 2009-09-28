class UserSchoolAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :school
  
 # has_one :access_key
 belongs_to :access_key
  
  has_enumerated :role 
end
