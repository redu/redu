class EnvironmentInvitationsController < BaseController
  def create
    @environment = Environment.find(params[:environment_id])
    @invitation = EnvironmentInvitation.new(params[:environment_invitation])
    @invitation.environment = @environment
    @invitation.user = current_user
    if @invitation.save
      @invitation.invite!
    end

    respond_to do |format|
        format.html
        format.js
    end
  end
end
