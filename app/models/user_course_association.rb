class UserCourseAssociation < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :course
  
  belongs_to :access_key
  has_enumerated :role
  
  # não tenho certeza se é aqui ou em user, coloquei em user has_many :acquisitions, :as => :acquired_by
  
end
