class ExamUser < ActiveRecord::Base

  belongs_to :user
  belongs_to :exam

  named_scope :ranking, lambda { |exam_id|
    { :conditions => ["exam_id = ? AND public = ?",exam_id, true], :include => :user, :order => "correct_count DESC, time ASC", :limit => 10 }
  }
end
