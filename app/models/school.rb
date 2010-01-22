class School < ActiveRecord::Base
  
  
    #acts_as_activity :owner
    
    has_many :user_school_association, :dependent => :destroy
    has_many :users, :through => :user_school_association
    
    has_many :coordinators, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 5 ]
    has_many :teachers, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 6 ]
    has_many :students, :through => :user_school_association, :source => :user, :conditions => [ "user_school_associations.role_id = ?", 7 ]

    has_many :acquisitions, :as => :acquired_by

    has_many :access_keys, :dependent => :destroy
    
    validates_presence_of :name
  
end
