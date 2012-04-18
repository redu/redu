class UserSession < Authlogic::Session::Base

  # Permite que o usuário efetue o log in tanto por login como por e-mail
  find_by_login_method :find_by_login_or_email

  remember_me_for 2.weeks
  remember_me false

end
