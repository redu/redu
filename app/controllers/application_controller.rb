class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user

  after_filter :check_tour_exploration

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,                            :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end

  rescue_from CanCan::AccessDenied do |exception|
    session[:return_to] ||= request.fullpath

    flash[:notice] = "Essa área só pode ser vista após você acessar o Redu com seu nome e senha."
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

  def last_request_update_allowed?
    false
  end

  def check_tour_exploration
    return if current_user.nil? || !params.has_key?(:exploring_tour)
    current_user.settings.visit!(request.path)
  end
end
