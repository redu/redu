module UserRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :login
  property :email
  property :first_name
  property :last_name
  property :birthday
  property :friends_count
  property :mobile
  property :localization
  property :birth_localization
  property :thumbnails
  property :created_at
  property :updated_at
  collection :social_networks, :extend => SocialNetworkRepresenter,
    :class => SocialNetwork


  #FIXME tornar isso genérico para qualquer thumbnail de qualquer entidade
  def thumbnails
    [ { :size => "32x32", :href => self.avatar.url(:thumb_32) },
      { :size => "110x110", :href => self.avatar.url(:thumb_110) } ]
  end

  link :self do
    api_user_url(self)
  end

  link :enrollments do
    api_user_enrollments_url(self)
  end

  link :statuses do
     api_user_statuses_url(self)
  end

  link :timeline do
    timeline_api_user_statuses_url(self)
  end

  link :contacts do
    api_user_contacts_url(self)
  end

end
