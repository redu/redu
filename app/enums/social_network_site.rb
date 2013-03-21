class SocialNetworkSite < ClassyEnum::Base
end

class SocialNetworkSite::Facebook < SocialNetworkSite
  def to_s
    "Facebook"
  end
end

class SocialNetworkSite::Twitter < SocialNetworkSite
  def to_s
    "Twitter"
  end
end

class SocialNetworkSite::Orkut < SocialNetworkSite
  def to_s
    "Orkut"
  end
end

class SocialNetworkSite::Linkedin < SocialNetworkSite
  def to_s
    "LinkedIn"
  end
end
