class Annotation < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :user
  alias :owner :user
  belongs_to :lecture

end
