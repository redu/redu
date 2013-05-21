# -*- encoding : utf-8 -*-
require 'oauth/controllers/provider_controller'
require 'oauth/provider/authorizer'

class OauthController < ApplicationController
  include OAuth::Controllers::ProviderController
  layout 'new_application'

  rescue_from CanCan::AccessDenied, :with => :deny_access

  def login_required
    authorize! :authorize_oauth, :base
  end

  def authorize
    @user = current_user
    if params[:oauth_token]
      @token = ::RequestToken.find_by_token! params[:oauth_token]
      oauth1_authorize
    else
      if request.post?
        @authorizer = OAuth::Provider::Authorizer.new current_user, user_authorizes_token?, params

        if URI.extract(@authorizer.redirect_uri).empty?
          @token = @authorizer.code
          render :action => :authorize_success
        else
          redirect_to @authorizer.redirect_uri
        end
      else
        @client_application = ClientApplication.find_by_key! params[:client_id]
        render :action => "oauth2_authorize"
      end
    end
  end

  def access_token
    @token = current_token && current_token.exchange!
    if @token
      render :text => @token.to_query
    else
      render :nothing => true, :status => 401
    end
  end


  protected
  # Override this to match your authorization page form
  # It currently expects a checkbox called authorize
  # def user_authorizes_token?
  #   params[:authorize] == '1'
  # end

  # Sobrescrito para lidar com callbacks vazios (PIN authentication)
  # http://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.1
  def oauth2_token_authorization_code
    @verification_code =  @client_application.oauth2_verifiers.find_by_token params[:code]
    unless @verification_code
      oauth2_error
      return
    end
    unless callback_match?(@verification_code, params)
      oauth2_error
      return
    end
    @token = @verification_code.exchange!
    render :json=>@token
  end

  def callback_match?(verification_code, params)
    @verification_code.redirect_url.blank? && params[:redirect_uri].blank? ||
       @verification_code.redirect_url == params[:redirect_uri]
  end

  def deny_access(exception, &block)
    super(exception) do
      flash.delete(:error)
    end
  end
end
