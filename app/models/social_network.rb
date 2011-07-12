class SocialNetwork < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :url

  enumerate :networks do
    value :id => 'facebook', :name => "facebook"
    value :id => 'twitter', :name => "twitter"
    value :id => 'orkut', :name => "orkut"
    value :id => 'linkedin', :name => "linkedin"
  end
end
