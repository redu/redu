class Course < ActiveRecord::Base

  acts_as_commentable

  has_and_belongs_to_many :subjects
  has_and_belongs_to_many :resources
  
  ajaxful_rateable :stars => 5#, :dimensions => [:speed, :beauty, :price]
  
  
  #has_many :students,  :source => :user, :conditions => ["role_id = ?",7]
  #has_many :teachers,  :source => :user, :conditions => ["role_id = ?",6] 
  #has_one :moderator,  :source => :user, :conditions => ["role_id = ?",2] 
  #has_one :school_admin,  :source => :user, :conditions => ["role_id = ?",4]
  
  has_many :acess_key
  
  validates_presence_of :name
  
  #has_and_belongs_to_many :subject
  #has_and_belongs_to_many :resource
  #has_and_belongs_to_many :question
  
end
