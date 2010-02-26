class Subscription < ActiveRecord::Base
  acts_as_enumerated
  validates_presence_of [:type , :name]
end
