# -*- encoding : utf-8 -*-
class UserSession < Authlogic::Session::Base

  # Permite que o usuário efetue o log in tanto por login como por e-mail
  find_by_login_method :find_by_login_or_email

  remember_me_for 2.weeks
  remember_me false

  skip_callback :persist, :persist_by_session
  skip_callback :after_save, :update_session
  skip_callback :after_destroy, :update_session
  skip_callback :after_persisting, :update_session
end
