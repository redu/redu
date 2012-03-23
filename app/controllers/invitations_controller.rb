class InvitationsController < ApplicationController

  layout "clean"

  def show
    begin
      @invitation = Invitation.find(params[:id])
      if current_user
        @invitation.accept!(current_user)
        redirect_to home_user_path(current_user)
      else
        @invitation_user = @invitation.user #remetente do convite
        uca = UserCourseAssociation.where(:user_id => @invitation_user).approved
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
    begin
      invitation = Invitation.find(params[:id])
      invitation.destroy
      flash[:notice] = "O convite foi removido com sucesso."
    rescue
      flash[:error] = "Nenhum convite para ser removido."
    end
    respond_to do |format|
      format.html { redirect_to home_user_path(current_user) }
    end
  end

  def destroy_invitations
    invitations = params[:invitations]
    friendship_requests = params[:friendship_requests]
    InvitationsUtil.destroy_invitations(params.to_hash, current_user)

    if params.key?(:friendship_requests) or params.key?(:invitations)
      flash[:notice] = "Os convites foram removidos com sucesso."
    else
      flash[:error] = "Nenhum convite foi selecionado para remoção."
    end

    respond_to do |format|
      format.html { redirect_to new_user_friendship_path(current_user) }
    end
  end

  def resend_email
    invitation = Invitation.find(params[:id])
    invitation.resend_email do |invitation|
      UserNotifier.friendship_invitation(invitation).deliver
    end
    respond_to do |format|
      format.js do
        @invitation_id = "invitation-#{invitation.id}"
        render 'invitations/resend_email'
      end
    end
  end
end
