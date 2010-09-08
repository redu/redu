# Groups are used to determine which groups of users have which rights
# on which folders.
class Group < ActiveRecord::Base
  has_many :group_user
  has_many :users, :through => :group_user
end