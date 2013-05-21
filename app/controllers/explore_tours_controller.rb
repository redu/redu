# -*- encoding : utf-8 -*-
class ExploreToursController < BaseController
  def create
    user = User.find(params[:user_id])
    authorize! :manage, user

    user.settings.visit!(params[:id])

    respond_to do |format|
      format.js { render :nothing => true, :status => 200 }
    end
  end
end
