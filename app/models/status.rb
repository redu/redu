class Status < ActiveRecord::Base
  
  # PLUGINS
  acts_as_commentable
  
  # ASSOCIATIONS
  belongs_to :user
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner_id"
  
end
