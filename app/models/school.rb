class School < ActiveRecord::Base
  
    has_many :user_school_association
    has_many :users, :through => :user_school_association
    
    has_many :teachers, :through => :user_school_association, :source => :user, :conditions => [ "role_id = ?", 2 ]
    has_many :students, :through => :user_school_association, :source => :user, :conditions => [ "role_id = ?", 1 ]


    has_many :access_keys
  
end
