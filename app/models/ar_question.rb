class ArQuestion < ActiveRecord::Base
  include SimpleActsAsList::ModelAdditions

  belongs_to :exercise
  has_many :answers, dependent: :destroy
  validates_presence_of :statement

  simple_acts_as_list :scope => :exercise_id

end
