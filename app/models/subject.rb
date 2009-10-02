class Subject < ActiveRecord::Base
  
  
  has_many :user_subject_association
  has_many :users, :through => :user_subject_association
  has_many :course_subject_association
  has_many :courses, :through => :course_subject_association
  
  has_many :students, :through => :user_subject_association, :source => :user, :conditions => ["role_id = ?",7]
  has_many :teachers, :through => :user_subject_association, :source => :user, :conditions => ["role_id = ?",6] 
  has_one :moderator, :through => :user_subject_association, :source => :user, :conditions => ["role_id = ?",2] 
  
  validates_presence_of :name
  
end
