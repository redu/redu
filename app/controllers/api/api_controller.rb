module Api
  class ApiController < ActionController::Base
    respond_to :json
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    def routing_error; bad_request end

    private

    def not_found
      respond_with nil, :status => :not_found
    end

    def bad_request
      respond_with nil, :status => :bad_request
    end

    def self.responder
      Class.new(super).send :include, Roar::Rails::Responder
    end

    protected

    def current_user
      token = Oauth2Token.find_by_token params[:oauth_token]
      token.try(:user)
    end
  end
end
