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

end
