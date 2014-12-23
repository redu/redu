class ArQuestion < ActiveRecord::Base

  belongs_to :exercise
  has_many :answers, dependent: :destroy
  validates_presence_of :statement

end
