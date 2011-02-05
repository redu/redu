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

        flash[:notice] = :thanks_youre_now_logged_in.l
        redirect_to home_user_path(current_user)
      else
        flash[:notice] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
        render :action => :new
      end
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = :youve_been_logged_out_hope_you_come_back_soon.l
    redirect_to new_session_path
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
