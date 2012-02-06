module Api
  class ApiController < ActionController::Base
    respond_to :json
    rescue_from ActiveRecord::RecordNotFound, :with => :error_404

    private

    def error_404
      respond_with nil, :status => 404
    end
  end
end
