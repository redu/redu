class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :lecture
  belongs_to :role

  def self.create_enrollment subject_id, current_user
    current_user.enrollments.create(:subject_id => subject_id)
  end
end
