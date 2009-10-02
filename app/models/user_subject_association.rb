class UserSubjectAssociation < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :subject
  
  belongs_to :access_key
  has_enumerated :role
  
end
