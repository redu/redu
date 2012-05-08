class AuthenticationsController < ApplicationController
  
  def create
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth[:provider],
                                                             auth[:uid])

    if authentication
      # Autenticação já existe.
      user = authentication.user
      unless current_user
        @user_session = UserSession.new(user)
        @user_session.save
      end
      flash[:notice] = t :thanks_youre_now_logged_in
      redirect_to home_user_path(user)
    else
      # Autenticação inexistente.
      user = User.find_by_email(auth[:info][:email])
      if user
        # Existe conta no Redu com o e-mail associado à conta do FB.
        user.authentications.create!(:provider => auth[:provider],
                                     :uid => auth[:uid])
        unless user.activated_at
          user.activated_at = Time.now
        end
        flash[:notice] = t :facebook_connect_account_association
      else
        # Não existe conta do Redu associada ao e-mail do usuário no FB. 
        user = Authentication.build_user(auth)
        user.update_attributes(:activated_at => Time.now)
        user.authentications.build(:provider => auth[:provider],
                                   :uid => auth[:uid])
        flash[:notice] = t :facebook_connect_new_user
      end

      # Tenta atualizar os dados do usuário (possivelmente recém-criado).
      if user.save
        @user_session = UserSession.new(user)
        @user_session.save
        # Usuário criado / atualizado com sucesso.
        redirect_to home_user_path(user)
      else
        # Erro ao criar / atualizar usuário.
        flash[:notice] = t :facebook_connect_error
        redirect_to home_path
      end
    end
  end
  
  def fallback
    flash[:notice] = t :you_need_give_us_access_to_your_facebook_data
    redirect_to home_path
  end

end
