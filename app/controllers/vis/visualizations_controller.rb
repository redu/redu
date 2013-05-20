# -*- encoding : utf-8 -*-
module Vis
  class VisualizationsController < ActionController::Base
    respond_to :json

    rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    rescue_from CanCan::AccessDenied do |exception|
      respond_with Error.new("Acesso negado").extend(ErrorRepresenter), :status => 401
    end

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

    def current_ability
      @current_ability ||= Ability.new(current_user)
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
end
