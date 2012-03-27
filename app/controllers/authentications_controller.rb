class AuthenticationsController < ApplicationController
  
  def create
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth[:provider],
                                                             auth[:uid])

    if authentication
      # Usuário cadastrado.
      user = authentication.user
      unless current_user
        @user_session = UserSession.new(user)
        @user_session.save
      end
      flash[:notice] = t :thanks_youre_now_logged_in
      redirect_to home_path
    else
      # Usuário não cadastrado.
      user = User.new
      user.authentications.build(:provider => auth['provider'],
                                 :uid => auth['uid'])
      user.apply_omniauth!(auth)

      if user.save
        # Usuário criado com sucesso.
        flash[:notice] = t :thanks_youre_now_logged_in
        redirect_to home_path
      else
        # Usuário não foi criado.
        flash[:notice] = "Não foi possível logar porque" +
                         user.errors.first.second.to_s
        redirect_to home_path
      end
    end
  end
  
  def fallback
    flash[:notice] = t :you_need_give_us_access_to_your_facebook_data
    redirect_to home_path
  end

end
