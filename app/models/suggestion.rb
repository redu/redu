class Suggestion < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :message
end
