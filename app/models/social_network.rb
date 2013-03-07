class SocialNetwork < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :url

  classy_enum_attr :networks, :enum => 'SocialNetworks'
end
