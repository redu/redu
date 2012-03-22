class InvitationsController < ApplicationController

  layout "clean"

  def show
    begin
      @invitation = Invitation.find(params[:id])
      if current_user
        @invitation.accept!(current_user)
        redirect_to home_user_path(current_user)
      else
        @user = @invitation.user #remetente do convite
        uca = UserCourseAssociation.where(:user_id => @user).approved
        @contacts = { :total => @user.friends.count }
        @courses = { :total => @user.courses.count,
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
    invitation = Invitation.find(params[:id])
    invitation.destroy
    #TODO:
  end

  def destroy_invitations
    invitations = params[:invitations]
    friendship_requests = params[:friendship_requests]
    #TODO:
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
