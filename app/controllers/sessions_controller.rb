class SessionsController < BaseController
  respond_to :html, :js

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

        # Invitation Token
        if params.has_key?(:friendship_invitation_token)
          invite = Invitation.find_by_token(params[:friendship_invitation_token])
          invite.accept!(current_user)
        end

        flash[:notice] = t :thanks_youre_now_logged_in

        render :js => "window.location = '#{ session[:return_to] || home_user_path(current_user) }'"
        session[:return_to] = nil
      else
        # Se tem um token de convite para o curso, atribui as variáveis
        # necessárias para mostrar o convite
        if params.has_key?(:invitation_token)
          @user_course_invitation = UserCourseInvitation.find_by_token(
            params[:invitation_token])
          @course = @user_course_invitation.course
          @environment = @course.environment
          render :template => 'user_course_invitations/show'

        elsif params.has_key?(:friendship_invitation_token)
          @invitation = Invitation.find_by_token(params[:friendship_invitation_token])
          @invitation_user = @invitation.user
          uca = UserCourseAssociation.where(:user_id => @invitation_user).approved
          @contacts = {:total => @invitation_user.friends.count}
          @courses = { :total => @invitation_user.courses.count,
                       :environment_admin => uca.with_roles([:environment_admin]).count,
                       :tutor => uca.with_roles([:tutor]).count,
                       :teacher => uca.with_roles([:teacher]).count }
          render :template => 'invitations/show'
        else
          respond_with(@user_session)
        end
      end
    end
  end

  def destroy
    session[:return_to] = nil
    current_user_session.destroy if current_user_session
    redirect_to home_path
  end

  protected

  def less_than_30_days_of_registration_required
    user = User.find_by_login_or_email(params[:user_session][:login])
    if user and not user.active? and not user.can_activate? # Passou do tempo de autenticar
      @user_email = user.email

      respond_to do |format|
        format.js
      end
    end
  end
end
