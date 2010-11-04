class UserEnvironmentAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :environment
  has_enumerated :role
end
