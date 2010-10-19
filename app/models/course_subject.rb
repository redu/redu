class CourseSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :courseable, :polymorphic => true, :dependent => :destroy
  has_many :student_profiles, :dependent => :destroy
 
  accepts_nested_attributes_for :courseable
  
end
