class InvitationsController < ApplicationController
  include InvitationsProcessor

  layout "clean"
  load_and_authorize_resource :invitation, :except => [:show]

  def show
    begin
      @invitation = Invitation.find(params[:id])
      if current_user
        @invitation.accept!(current_user)
        redirect_to home_user_path(current_user)
      else
        @invitation_user = @invitation.user #remetente do convite
        uca = @invitation_user.user_course_associations.approved
        @contacts = { :total => @invitation_user.friends.count }
        @courses = { :total => @invitation_user.courses.count,
                     :environment_admin => uca.with_roles([:environment_admin]).count,
                     :tutor => uca.with_roles([:tutor]).count,
                     :teacher => uca.with_roles([:teacher]).count
        }
        @user_session = UserSession.new
      end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Este convite já foi utilizado."
      redirect_to home_path
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy
    flash[:notice] = "O convite foi removido com sucesso."

    respond_to do |format|
      format.js
      format.html { redirect_to home_user_path(current_user) }
    end
  end

  def destroy_invitations
    invitations = params[:invitations_ids] || ""
    invitations = invitations.collect do |id|
      begin
        invitation = Invitation.find(id)
        authorize! :destroy, invitation
        invitation
      rescue
      end
    end

    friendship_requests = params[:friendship_requests] || ""
    friendship_requests = friendship_requests.collect do |id|
      begin
        friendship_request = Friendship.find(id)
        authorize! :destroy, friendship_request
        friendship_request
      rescue
      end
    end

    batch_destroy_invitations(invitations, current_user)
    batch_destroy_friendships(friendship_requests, current_user)

    if params.key?(:friendship_requests) or params.key?(:invitations_ids)
      flash[:notice] = "Os convites foram removidos com sucesso."
    else
      flash[:error] = "Nenhum convite foi selecionado para remoção."
    end

    respond_to do |format|
      format.html { redirect_to new_user_friendship_path(current_user) }
    end
  end

  def resend_email
    begin
      authorize! :resend_email, @invitation
      @invitation.resend_email do |invitation|
        UserNotifier.delay(:queue => 'email').friendship_invitation(invitation)
      end
    rescue
    end

    respond_to do |format|
      format.js do
        @invited = @invitation.email
        @invitation_id = "invitation-#{@invitation.id}"
        render 'invitations/resend_email'
      end
    end
  end
end
