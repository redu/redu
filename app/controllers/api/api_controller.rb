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
  end
end
