module Api
  class ApiController < ActionController::Base
    respond_to :json
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    rescue_from ActiveModel::MissingAttributeError, :with => :bad_request

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
      token = get_header_token
      token ||= params[:oauth_token]
      token = OauthToken.verify_token token
      token.try(:user)
    end

    def get_header_token
      header_value = request.headers["HTTP_AUTHORIZATION"]
      # matches oauth_token="dCmauo5E3GVIpi5oh6c8kBIqapFCFfnvZUE6vdds"
      # and oauth_token = 'dCmauo5E3GVIpi5oh6c8kBIqapFCFfnvZUE6vdds'
      reg = /oauth_token(?:\s+)?=(?:\s+)?(?:\"|\')(\w+)(?:\"|\')\s?/i
      token = reg.match(header_value)[1] unless header_value.nil?
      token
    end
  end
end
