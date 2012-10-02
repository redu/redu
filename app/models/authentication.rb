class Authentication < ActiveRecord::Base
  belongs_to :user
  validates :uid, :provider, :presence => true
  validates_uniqueness_of :uid, :scope => :provider

  # Authentication.create_user cria um novo usuário a partir da hash do oauth
  # utilizando o método User.create_with_omniauth e adicionando apenas atributos
  # específicos da autorização (não obrigatórios de acordo com as validações)
  def self.create_user(omniauth_hash)
    user = User.create_with_omniauth(omniauth_hash)
    info = omniauth_hash[:info]
    if info[:image]
      # Atualiza o avatar do usuário de acordo com seu avatar no Facebook (se não for o default).
      unless info[:image] == "http://graph.facebook.com/100002476817463/picture?type=square"
        user.avatar = open(info[:image])
        user.save
      end
    end

    user
  end

  # Authentication.get_login_from_facebook_nickname retorna um atributo que é
  # específico de autorização (FB-connect, no caso) e é invocado a partir de
  # User.create_with_omniauth
  def self.get_login_from_facebook_nickname(info_hash)
    login = info_hash[:nickname].delete('. ') if info_hash[:nickname]
    unless login
      # Usuário não possui um nickname no Facebook.
      # Gera login a partir de nome e sobrenome.
      login = "#{info_hash[:first_name]}#{info_hash[:last_name]}"
      login = login.delete('. ').parameterize
    end

    # Verifica se já existe um login
    get_nonexistent_login(login, nil)
  end

  private

  def self.get_nonexistent_login(login, n)
    if !User.find_by_login("#{login}#{n}")
      return "#{login}#{n}"
    else
      n = 0 unless n != nil
      self.get_nonexistent_login(login, n+1)
    end
  end

end
