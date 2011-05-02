class Annotation < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :user
  alias :owner :user
  belongs_to :lecture

  scope :by_user, lambda { |user_id| where("user_id  = ?", user_id) }

end
