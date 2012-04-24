class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,                            :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:notice] = "Você não tem acesso a essa página"
    redirect_to home_path
  end

  def routing_error
    respond_to do |format|
      format.html {
        render :template => 'errors/404', :layout => 'cold', :status => '404'
      }
    end
  end

  private

  # Handlers para exceções (paginas de error customizadas)
  def render_not_found(exception)
    logger.error exception
    respond_to do |format|
      format.html {
        render :template => 'errors/404', :layout => 'cold', :status => '404'
      }
    end
  end

  def render_error(exception)
    @contact = Contact.new
    logger.error exception
    respond_to do |format|
      format.html {
        render :template => 'errors/500', :layout => 'cold', :status => '500'
      }
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

end
