class ExamUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :exam

  scope :ranking, lambda { |exam_id|
    where("exam_id = ? AND public = ?",exam_id, true).includes(:user).
      order("correct_count DESC, time ASC").limit(10)
  }
end
