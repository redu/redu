module FriendshipRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :status
  property :contact, :extend => UserPartialRepresenter, :class => User
  property :user, :extend => UserPartialRepresenter, :class => User

  def contact
    self.friend
  end

  link :self do
    api_friendship_url(self)
  end

  link :contact do
    api_user_url(self.friend)
  end

  link :user do
    api_user_url(self.user)
  end
end
