class SocialNetwork < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :url

  enumerate :networks do
    value :id => 'facebook', :name => "Facebook"
    value :id => 'twitter', :name => "Twitter"
    value :id => 'orkut', :name => "Orkut"
    value :id => 'linkedin', :name => "LinkedIn"
  end
end
