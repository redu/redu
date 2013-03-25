module FriendshipRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :status

  #TODO Fazer um representar menor para User
  property :contact, :extend => UserRepresenter, :class => User
  property :user, :extend => UserRepresenter, :class => User

  def contact
    self.friend
  end

  link :self do
    api_friendship_url(self)
  end

  link :contact do
    api_user_url(self.user)
  end

  link :user do
    api_user_url(self.user)
  end
end
