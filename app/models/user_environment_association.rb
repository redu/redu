class UserEnvironmentAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :environment

  validates_uniqueness_of :user_id, :scope => :environment_id
end
