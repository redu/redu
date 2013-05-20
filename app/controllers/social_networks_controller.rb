# -*- encoding : utf-8 -*-
class SocialNetworksController < ApplicationController
  respond_to :js

  load_and_authorize_resource :user, :find_by => :login
  load_and_authorize_resource :social_network, :through => :user

  def destroy
    @social_network.destroy
    respond_with(@user, @social_network)
  end

end
