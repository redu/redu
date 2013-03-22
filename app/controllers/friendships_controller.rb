class FriendshipsController < BaseController
  include InvitationsProcessor

  load_and_authorize_resource :user, :find_by => :login
  load_and_authorize_resource :friendship, :through => :user

  def index
    @profile = params[:profile] if params.has_key? :profile
    @total_friends = @user.friends.count
    @friends = @user.friends.
      paginate(:page => params[:page], :per_page => 16)

    respond_to do |format|
      format.html do
        render :layout => 'new_application'
      end
      format.js { render_endless 'users/item_medium', @friends, '#contacts > ul' }
    end
  end

  def new
    @invitations = @user.invitations
    @friendship_requests = @user.friendships.requested
    @contacts_recommendations = @user.recommended_contacts(5)

    respond_to do |format|
      format.html do
        render :layout => 'new_application'
      end
    end
  end

  def create
    @friend = process_invites(params.to_hash, current_user)
    respond_to do |format|
      format.html do
        if params.has_key? :goto_home
          redirect_to home_user_path(current_user)
        elsif params.has_key? :goto_invitations
          if params[:emails].to_s.gsub(',', ' ').strip != "" || params[:friend_id].to_s.strip != ""
            flash[:notice] = "Convites enviados com sucesso."
          else
            flash[:error] = "Nenhum convite para ser enviado."
          end
          redirect_to new_user_friendship_path(current_user)
        else
          redirect_to user_path(@friend)
        end
      end
      format.js do
        @show_user = params.has_key? :show_user
        @recommendation = params.has_key? :recommendation
      end
    end
  end

  def destroy
    @friend = User.find(@friendship.friend_id)
    destroy_friendship(@friend)
    respond_to do |format|
      format.html do
        if params.has_key? :goto_home
          redirect_to home_user_path(current_user)
        else
          redirect_to user_path(@friend)
        end
      end
      format.js
    end
  end

  def resend_email
    user = @friendship.user
    friend = @friendship.friend
    UserNotifier.delay(:queue => 'email').friendship_requested(friend, user)
    respond_to do |format|
      format.js do
        @invitation_id = "request-#{params[:id]}"
        render 'invitations/resend_email'
      end
    end
  end

  protected
  def destroy_friendship(choosen_user)
    friendship_in = current_user.friendship_for(choosen_user)
    friendship_out = choosen_user.friendship_for(current_user)
    # FIXME só deletar se existir conexão
    friendship_in.destroy
    friendship_out.destroy
  end

end
