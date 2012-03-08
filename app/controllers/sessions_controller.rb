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
    info = request.env['omniauth.auth']['info']
    user = User.find_by_email(info['email'])
    if user
      @user_session = UserSession.new(:remember_be => '0', 
                                      :login => user.login)
      @user_session.save do |result|
        if result
          current_user = @user_session.record

          flash[:notice] = t :thanks_youre_now_logged_in
          redirect_to home_user_path(current_user)
        else
          raise info.to_yaml
        end
      end
    else
      # raise info.to_yaml
      user = User.new_from_facebook(info)
      user.save
      redirect_to home_path
    end
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
