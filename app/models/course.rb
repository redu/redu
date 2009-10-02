class Course < ActiveRecord::Base
  
  has_many :user_course_association
  has_many :users, :through => :user_course_association
  has_many :course_subject_association
  has_many :subjects, :through => :course_subject_association
  
  has_many :students, :through => :user_course_association, :source => :user, :conditions => ["role_id = ?",7]
  has_many :teachers, :through => :user_course_association, :source => :user, :conditions => ["role_id = ?",6] 
  has_one :moderator, :through => :user_course_association, :source => :user, :conditions => ["role_id = ?",2] 
  has_one :school_admin, :through => :user_course_association, :source => :user, :conditions => ["role_id = ?",4]
  
  has_many :acess_key
  
  validates_presence_of :name
  
  #has_and_belongs_to_many :subject
  #has_and_belongs_to_many :resource
  #has_and_belongs_to_many :question
  
end
