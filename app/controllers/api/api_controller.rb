module Api
  class ApiController < ActionController::Base
    respond_to :json
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    def routing_error; bad_request end

    private

    def not_found
      # respond_with({}, :status => :not_found)
      respond_to do |format|
        format.json { render :nothing => true, :status => :not_found }
      end
    end

    def bad_request
      # respond_with({}, :status => :bad_request)
      respond_to do |format|
        format.json { render :nothing => true, :status => :bad_request }
      end
    end

    def self.responder
      Class.new(super).send :include, Api::Responder
    end

    protected

    def current_user
      token = Oauth2Token.find_by_token params[:oauth_token]
      token.try(:user)
    end
  end
end
