class Authentication < ActiveRecord::Base
  belongs_to :user
  validates :uid, :provider, :presence => true
  validates_uniqueness_of :uid, :scope => :provider

  def self.create_user(omniauth)
    user = User.new
    info = omniauth[:info]
    user.email = info[:email]
    user.reset_password
    user.tos = '1'
    user.update_attributes(:activated_at => Time.now)
    user.authentications.build(:provider => omniauth[:provider],
                               :uid => omniauth[:uid])

    # Cria novo usuário a partir de hash do Omniauth.
    case omniauth[:provider]
    when 'facebook'
      user.login = get_login_from_facebook_nickname(info)
      user.first_name = info[:first_name]
      user.last_name = info[:last_name]
      if info[:image]
        # Atualiza o avatar do usuário de acordo com seu avatar no Facebook (se não for o default).
        if info[:image] != "http://graph.facebook.com/100002476817463/picture?type=square"
          user.avatar = open(info[:image])
        end
      end
    end
    user.save
    user.create_settings!

    user
  end

  private

  def self.get_login_from_facebook_nickname(info_hash)
    login = info_hash[:nickname]

    if !login
      # Usuário não possui um nickname no Facebook.
      # Gera login a partir de nome e sobrenome.
      login = "#{info_hash[:first_name]}#{info_hash[:last_name]}"
      login = login.delete(' ').parameterize
    end

    # Verifica se já existe um login
    get_nonexistent_login(login, nil)
  end

  def self.get_nonexistent_login(login, n)
    if !User.find_by_login("#{login}#{n}")
      return "#{login}#{n}"
    else
      n = 0 unless n != nil
      self.get_nonexistent_login(login, n+1)
    end
  end

end
