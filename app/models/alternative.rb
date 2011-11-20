class Alternative < ActiveRecord::Base
  belongs_to :question
  has_many :choices, :dependent => :destroy

  validates_presence_of :text
  validates_uniqueness_of :correct, :scope => :question_id,
    :if => Proc.new { |a| a.correct? }
end
