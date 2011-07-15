class Partner < ActiveRecord::Base
  has_many :partner_environment_associations
  has_many :environments, :through => :partner_environment_associations
  has_many :users

  validates_presence_of :name
end
