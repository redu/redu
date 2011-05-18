class FriendshipsController < BaseController

  load_and_authorize_resource :user
  load_and_authorize_resource :friendship, :through => :user

  def index
    @profile = params[:profile] if params.has_key? :profile
    @friends = @user.friends.
      paginate(:page => params[:page], :per_page => 16)

    respond_to do |format|
      format.html
      format.js { render_endless 'users/item_medium', @friends, '#contacts > ul' }
    end
  end

  def create
    @friend = User.find(params[:friend_id])
    current_user.be_friends_with(@friend)
    friendship = @friend.friendship_for current_user
    respond_to do |format|
      format.html do
        if params.has_key? :goto_home
          redirect_to home_user_path(current_user)
        else
          redirect_to user_path(@friend)
        end
      end
      format.js do
        @show_user = false
        @show_user = true if params[:show_user]
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

  # Controlador não acessível a partir das views
  def pending
    @friends_pending = @user.friends_pending.
      paginate({:page => params[:page], :per_page => 10})

    respond_to do |format|
      format.html
      format.js do
        render_endless 'friendships/item_pending', @friends_pending, '#pending_list'
      end
    end
  end

  def accept
    @friend = User.find(params[:friend_id])
    current_user.be_friends_with(@friend)
    respond_to do |format|
      format.html do
        redirect_to pending_user_friendships_path(current_user)
      end
      format.js
    end
  end

  def decline
    destroy_friendship(@friendship.friend)
    respond_to do |format|
      format.html do
        redirect_to user_path(@friendship.friend)
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
