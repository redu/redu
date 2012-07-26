class AuthenticationsController < BaseController

  def create
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth[:provider],
                                                             auth[:uid])

    if authentication
      # Autenticação já existe.
      user = authentication.user
      @user_session = UserSession.new(user)
      current_user = @user_session.record if @user_session.save
      flash[:notice] = t :thanks_youre_now_logged_in

      redirect_to session[:return_to] || home_user_path(current_user)
      session[:return_to] = nil
    else
      # Autenticação inexistente.
      user = User.find_by_email(auth[:info][:email])
      if user
        # Existe conta no Redu com o e-mail associado à conta do FB.
        user.authentications.create!(:provider => auth[:provider],
                                     :uid => auth[:uid])
        user.activated_at ||= Time.now
        flash[:notice] = t :facebook_connect_account_association
      else
        # Não existe conta do Redu associada ao e-mail do usuário no FB.
        user = Authentication.build_user(auth)
        user.update_attributes(:activated_at => Time.now)
        user.authentications.build(:provider => auth[:provider],
                                   :uid => auth[:uid])
        flash[:notice] = t :facebook_connect_new_user
      end

      begin
        if user.save
          @user_session = UserSession.new(user)
          current_user = @user_session.record if @user_session.save
          # Usuário criado / atualizado com sucesso.
          redirect_to session[:return_to] || home_user_path(current_user)
          session[:return_to] = nil
        else
          # Erro ao criar / atualizar usuário.
          flash[:notice] = t :facebook_connect_error
          redirect_to application_path
        end
      # FIXME Após migrar o Rails (> 3.0.10) ver se a solução clean funciona.
      # Necessário pois o rescue_from estava dando conflito com o
      # rescue_from Exception (mais geral). See #863.
      rescue ActiveRecord::RecordNotUnique
        flash[:notice] = t :facebook_connect_error
        redirect_to application_path
      end
    end
  end

  def fallback
    flash[:notice] = t :you_need_give_us_access_to_your_facebook_data
    redirect_to application_path
  end

end
