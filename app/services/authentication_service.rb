# -*- encoding : utf-8 -*-
class AuthenticationService
  attr_reader :omniauth, :authenticated_user, :name_service

  def initialize(opts={})
    @omniauth = opts[:omniauth]
    @name_service = NameService.new(:min_length => User::MIN_LOGIN_LENGTH,
                                    :max_length => User::MAX_LOGIN_LENGTH)
    @connected_accounts = false
  end

  def authentication
    @authentication ||= Authentication.where(omniauth.slice(:provider, :uid)).first
  end

  def connected_accounts?
    @connected_accounts
  end

  def authenticate?
    @authenticated_user = authentication.try(:user) || connect_accounts ||
      create_user_from_omniauth

    authenticated_user.present? && !authenticated_user.new_record?
  end

  # Conecta conta do facebook com a conta já existente no Redu
  def connect_accounts
    if user = User.find_by_email(omniauth[:info][:email])
      user.update_attribute(:activated_at, Time.now) unless user.activated_at
      user.authentications.create!(:provider => omniauth[:provider],
                                   :uid => omniauth[:uid])
      @connected_accounts = true
    end
    user
  end

  # Inicializa o usuário baseado nos dados do omniauth
  def build_user
    return nil unless omniauth

    User.new do |u|
      u.enable_humanizer = false
      u.login = name_service.valid_login(omniauth[:info])
      u.email = omniauth[:info][:email]
      u.reset_password
      u.tos = '1'
      u.first_name = omniauth[:info][:first_name]
      u.last_name = omniauth[:info][:last_name]
      u.activated_at = Time.now
      u.authentications.build(:provider => omniauth[:provider],
                              :uid => omniauth[:uid])
      u.avatar = get_avatar
    end
  end

  private

  # Cria o usuário baseado nos parâmetros do omniauth
  def create_user_from_omniauth
    user = build_user

    begin
      user.save
      user.create_settings!
    rescue ActiveRecord::RecordNotUnique # Problema de concorrência no BD
      user = User.find_by_email(omniauth[:info][:email])
    end

    user
  end

  # Retorna avatar usado no Facebook se este não for o default de lá
  def get_avatar
    if omniauth[:info][:image].try(:=~, /http:\/\/graph.facebook.com\/\d\/picture\?type=square/)
      open(omniauth[:info][:image])
    end
  end
end
