class Role < ActiveRecord::Base
  acts_as_enum :name_column => 'name'
  validates_presence_of :name
  validates_uniqueness_of :name
end

