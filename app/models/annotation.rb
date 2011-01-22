class Annotation < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :user
  alias :owner :user
  belongs_to :lecture

  named_scope :by_user, lambda { |user_id|
    { :conditions => ["user_id = ?", user_id]}
  }

end
