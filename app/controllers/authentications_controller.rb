class AuthenticationsController < ApplicationController
  
  def create
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth[:provider],
                                                             auth[:uid])

    if authentication
      # Usuário cadastrado.
      flash[:notice] = t :thanks_youre_now_logged_in
      sign_in_and_redirect(authentication.user)
    elsif current_user
      # Usuário está logado mas não tem autenticação com este provedor.
      current_user.authentications.create!(:provider => auth[:provider],
                                           :uid => auth['uid'])
      current_user.apply_omniauth(auth)
      current_user.save

      flash[:notice] = "Autenticado com sucesso."
    else
      # Usuário não cadastrado.
      user = User.new
      user.authentications.build(:provider => auth['provider'],
                                 :uid => auth['uid'])
      user.apply_omniauth(auth)

      if user.save
        flash[:notice] = t :thanks_youre_now_logged_in
        sign_in_and_redirect(user)
      else
        user.valid?
        flash[:notice] = user.errors.to_s
        redirect_to home_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Autenticação destruída com sucesso!"
    redirect_to authentications_url
  end

  def facebook_registration
    debugger
    if params[:signed_request]
      value = params[:signed_request]
      signature, encoded_payload = value.split('.')

      decoded_hex_signature = base64_decode_url(signature)
      decoded_payload = MultiJson.decode(base64_decode_url(encoded_payload))

      unless decoded_payload['algorithm'] == 'HMAC-SHA256'
        raise NotImplementedError, "unknown algorithm: #{decoded_payload['algorithm']}"
      end
    end
  end

  private

  def sign_in_and_redirect(user)
    unless current_user
      @user_session = UserSession.new(User.find_by_single_access_token(user.single_access_token))
      @user_session.save
    end
    # current_user = @user_session.record
    redirect_to home_user_path(@user_session.record)
  end

  # Método utilizado para decodificação de dados da signed_request do facebook.
  def valid_signature?(secret, signature, payload, algorithm = OpenSSL::Digest::SHA256.new)
    OpenSSL::HMAC.digest(algorithm, secret, payload) == signature
  end

  # Método utilizado para decodificação de dados da signed_request do facebook.
  def base64_decode_url(value)
    value += '=' * (4 - value.size.modulo(4))
    Base64.decode64(value.tr('-_', '+/'))
  end

end
