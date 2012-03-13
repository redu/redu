class SessionsController < BaseController
  layout 'clean'
  before_filter :less_than_30_days_of_registration_required, :only => :create

  def index
    redirect_to :action => "new"
  end

  def new
    redirect_to home_user_path(current_user) and return if current_user
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])

    @user_session.save do |result|

      if result
        current_user = @user_session.record
        # Se tem um token de convite para o curso, aprova o convite para o
        # usuário recém-logado
        if params.has_key?(:invitation_token)
          invite = UserCourseInvitation.find_by_token(params[:invitation_token])
          invite.user = current_user
          invite.accept!
        end

        flash[:notice] = t :thanks_youre_now_logged_in
        redirect_to home_user_path(current_user)
      else
        # Se tem um token de convite para o curso, atribui as variáveis
        # necessárias para mostrar o convite
        if params.has_key?(:invitation_token)
          @user_course_invitation = UserCourseInvitation.find_by_token(
            params[:invitation_token])
          @course = @user_course_invitation.course
          @environment = @course.environment
          render :template => 'user_course_invitations/show'
        else
          render :template => 'base/site_index'
        end
      end
    end
  end

  def destroy
    current_user_session.destroy if current_user_session
    redirect_to home_path
  end

  def omniauth_fb_authenticated
    auth = request.env['omniauth.auth']
    user = User.find_by_external_uid(auth['uid'])
    if user
      #debugger
      @user_session = UserSession.new(user, true) 
      @user_session.save do |result|
        # raise request.env['omniauth.auth'].to_yaml
        if result
          current_user = @user_session.record

          flash[:notice] = t :thanks_youre_now_logged_in
          redirect_to home_user_path(current_user)
        else
          raise info.to_yaml
        end
      end
    else
      #raise request.env['omniauth.auth'].to_yaml
      render 'facebook_registration'
      #user = User.new_from_facebook(auth)
      #user.save
      #redirect_to home_path
    end
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

  def valid_signature?(secret, signature, payload, algorithm = OpenSSL::Digest::SHA256.new)
    OpenSSL::HMAC.digest(algorithm, secret, payload) == signature
  end

  def base64_decode_url(value)
    value += '=' * (4 - value.size.modulo(4))
    Base64.decode64(value.tr('-_', '+/'))
  end

  protected

  def less_than_30_days_of_registration_required
    user = User.find_by_login_or_email(params[:user_session][:login])
    if user and not user.active? and not user.can_activate? # Passou do tempo de autenticar
      @user_email = user.email
      render :template => 'sessions/expired_activation', :layout => 'application'
    end
  end

end
