class Subject < ActiveRecord::Base
  
=begin  
  has_many :user_subject_association
  has_many :users, :through => :user_subject_association
  has_many :course_subject_association
  has_many :courses, :through => :course_subject_association
=end

  has_and_belongs_to_many :resources
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :forums
  
  has_many :users, :through => :user_subject_association
  has_many :students, :through => :user_subject_association, :source => :user, :conditions => ["role_id = ?",7]
  has_many :teachers, :through => :user_subject_association, :source => :user, :conditions => ["role_id = ?",6] 
  has_one :moderator, :through => :user_subject_association, :source => :user, :conditions => ["role_id = ?",2] 
  
  validates_presence_of :name
  
end
