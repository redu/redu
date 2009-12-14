class ExamUser < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :exam
  
end
