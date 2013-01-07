class AuthenticationsController < BaseController

  def create
    logger.info "Logging in with facebook" # Logging
    logger.info request.env['omniauth.auth']
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth[:provider],
                                                             auth[:uid])
    current_user = nil
    if authentication # Autenticação já existe
      user = authentication.user
      @user_session = UserSession.new(user)
      current_user = @user_session.record if @user_session.save
      flash[:notice] = t :thanks_youre_now_logged_in
    else # Autenticação inexistente
      user = User.find_by_email(auth[:info][:email])
      if user # Existe conta no Redu com o e-mail associado à conta do FB
        user.activated_at ||= Time.now
        user.authentications.create!(:provider => auth[:provider],
                                     :uid => auth[:uid])
        flash[:notice] = t :facebook_connect_account_association
      else # Não existe conta do Redu associada ao e-mail do usuário no FB
        begin
          user = User.create_with_omniauth(auth)
        rescue ActiveRecord::RecordNotUnique
          user = User.find_by_email(auth[:info][:email])
        end
        flash[:notice] = t :facebook_connect_new_user
      end

      # Usuário criado / atualizado com sucesso
      @user_session = UserSession.new(user)
      current_user = @user_session.record if @user_session.save
    end

    # Lida com tokens de convites
    Authentication.handle_invitation_token(params[:state], current_user) if params[:state]

    if valid_url?(params[:state])
      redirect_to params[:state]
    else
      redirect_to session[:return_to] || home_user_path(current_user)
      session[:return_to] = nil
    end
  end

  def fallback
    flash[:error] = t :you_need_give_us_access_to_your_facebook_data
    redirect_to application_path
  end

  private

  # Verifica se a url pertence ao domínio de algum serviço do Redu
  #
  # valid_url?("http://aplicativos.redu.com.br/apps/86")
  # => true
  #
  # valid_url?("http://hack.com")
  # => false
  def valid_url?(url)
    Redu::Application.config.redu_services.values.collect do |service|
      url.try(:include?, service[:url])
    end.inject(:^)
  end
end
