class AuthenticationsController < ApplicationController
  
  def create
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth[:provider],
                                                             auth[:uid])

    if authentication
      # Usuário cadastrado.
      flash[:notice] = t :thanks_youre_now_logged_in
      sign_in_and_redirect(authentication.user)
    else
      # Usuário não cadastrado.
      user = User.new
      user.authentications.build(:provider => auth['provider'],
                                 :uid => auth['uid'])
      user.apply_omniauth!(auth)

      if user.save
        # Usuário criado com sucesso.
        flash[:notice] = t :thanks_youre_now_logged_in
        sign_in_and_redirect(user)
      else
        # Usuário não foi criado.
        flash[:notice] = "Não foi possível logar porque" +
                         user.errors.first.second.to_s
        redirect_to home_path
      end
    end
  end
  
  def fallback
    flash[:notice] = "Para logar com Facebook, você precisa permitir o Redu."
    redirect_to home_path
  end

  private

  def sign_in_and_redirect(user)
    unless current_user
      @user_session = UserSession.new(User.find_by_single_access_token(user.single_access_token))
      @user_session.save
    end
    redirect_to user_path(user)
  end

end
