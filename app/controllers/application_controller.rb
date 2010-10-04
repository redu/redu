class ApplicationController < ActionController::Base

  unless ActionController::Base.consider_all_requests_local
    rescue_from Exception,                            :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end

  private

    # Handlers para exceções (paginas de error customizadas)
    def render_not_found(exception)
      log_error(exception)
      respond_to do |format|
        format.html {
          render :template => 'errors/404', :layout => 'errors', :status => '404'
        }
      end
    end

    def render_error(exception)
      log_error(exception)
      respond_to do |format|
        format.html {
          render :template => 'errors/500', :layout => 'errors', :status => '500'
        }
      end
    end
end
