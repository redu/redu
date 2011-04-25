class SessionsController < BaseController
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

        flash[:notice] = :thanks_youre_now_logged_in.l
        redirect_to home_user_path(current_user)
      else
        # Se tem um token de convite para o curso, atribui as variáveis
        # necessárias para mostrar o convite
        if params.has_key?(:invitation_token)
          @user_course_invitation = UserCourseInvitation.find_by_token(
            params[:invitation_token])
          @course = @user_course_invitation.course
          @environment = @course.environment
          render :layout => 'new/clean',
            :template => 'user_course_invitations/show'
        else
          render :layout => false, :template => 'base/site_index'
        end
      end
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to home_path
  end

  protected

  def less_than_30_days_of_registration_required
    user = User.find_by_login_or_email(params[:user_session][:login])
    if user and not user.active? and not user.can_activate? # Passou do tempo de autenticar
      @user_email = user.email
      render :action => 'expired_activation'
    end
  end

end
