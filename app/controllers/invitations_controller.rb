class InvitationsController < BaseController
  before_filter :login_required

  def index
    @user = current_user
    @invitations = @user.invitations

    respond_to do |format|
      format.html
    end
  end

  def new
    @user = current_user
    @invitation = Invitation.new
  end


  def edit
    @invitation = Invitation.find(params[:id])
  end


  def create
    @user = current_user
    @inviteable = find_inviteable

    @invitation = Invitation.new(params[:invitation])
    @invitation.user = @user
    @invitation.inviteable = @inviteable
    @invitation.role = Role[:teacher] if @invitation.inviteable_type == 'Course'

    respond_to do |format|
      if @invitation.save
        @user.update_attribute(:has_invited, true)
        @invitation.invite!
        flash[:notice] = :invitation_was_successfully_created.l
        format.html {
          unless params[:welcome]
            redirect_to user_path(@invitation.user)
          else
            redirect_to welcome_complete_user_path(@invitation.user)
          end
        }
        format.js
      else
        format.html { render :action => "new" }
        format.js
      end
    end
  end

  protected

  # DRY: Por invitation ser polimorfico, concentrando todos os finds aqui
  def find_inviteable
    case
    when params[:environment_id] then Environment.find(params[:environment_id])
    when params[:course_id] then Course.find(params[:course_id])
    end
  end
end
