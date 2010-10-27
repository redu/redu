class Annotation < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :user
  belongs_to :lecture

end
