module Api
  class ApiController < ActionController::Base
    check_authorization
    respond_to :json
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    rescue_from ActiveModel::MissingAttributeError, :with => :bad_request
    rescue_from CanCan::AccessDenied, :with => :not_authorized

    def routing_error; bad_request end

    private

    def not_authorized
      authorize! :read, :error
      error = { :message => 'not authorized', :action => params[:action] }
      respond_to do |format|
        format.json { render :json => error, :status => :unauthorized }
      end
    end

    def not_found
      authorize! :read, :error

      respond_to do |format|
        format.json { render :nothing => true, :status => :not_found }
      end
    end

    def bad_request
      authorize! :read, :error
      respond_to do |format|
        format.json { render :nothing => true, :status => :bad_request }
      end
    end

    def self.responder
      Class.new(super).send :include, Api::Responder
    end

    def current_ability
      @current_ability = Api::Ability.new(current_user)
    end

    protected

    def current_user
      current_access_token.try(:user)
    end

    def current_access_token
      env["oauth.token"]
    end
  end
end
