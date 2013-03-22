class SocialNetwork < ActiveRecord::Base
  belongs_to :user

  classy_enum_attr :name, :enum => 'SocialNetworkSite'
  validates_presence_of :url
end
