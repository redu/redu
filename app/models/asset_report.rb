class AssetReport < ActiveRecord::Base
  # Modelo intermediário que especifica que um User finalizou uma determinada
  # Lecture dentro de um subject.

  belongs_to :student_profile
  belongs_to :lecture
  belongs_to :subject

  named_scope :done, :conditions => { :done => true }
  named_scope :of_subject, lambda { |subject_id|
    { :conditions => { :subject_id => subject_id } }
  }
  named_scope :of_user, lambda { |user_id|
    {:joins => :student_profile,
     :conditions => [ "student_profiles.user_id = ?", user_id ] }
  }
end
