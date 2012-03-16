class InvitationsController < ApplicationController
  layout 'clean'

  def index
    #TODO: list all invitations
    #FIXME: invites|frienship request mostradas via mesmo action?
  end

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
    rescue
      flash[:error] = "Este convite já foi utilizado."
      redirect_to home_path
    end
  end

  def create
    #Action criação de invitaiton (Via API)
  end

  def destroy
    #Action remoção de invitation
  end
end
