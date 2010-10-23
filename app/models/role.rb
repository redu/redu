class Role < ActiveRecord::Base
  
  validates_presence_of :name
  
  acts_as_enumerated

end

