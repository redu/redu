class FriendshipsController < BaseController

  load_and_authorize_resource :user
  load_and_authorize_resource :friendship, :through => :user

  def index
    @friends =
      @user.friends.paginate( {:page => params[:page], :per_page => 10 } )
  end

  def create
    @friend = User.find(params[:friend_id])
    current_user.be_friends_with(@friend)
    friendship = @friend.friendship_for current_user
    respond_to do |format|
      format.html do
        redirect_to user_path(@friend)
      end
      format.js do
        render :update do |page|
          if !current_user.friends? @friend
            page.insert_html :after, 'follow_link',
              (link_to 'Aguardando aceitação', nil, :class => 'waiting')
          end
          page.remove 'follow_link'
        end
      end
    end
  end

  def destroy
    @friend = User.find(@friendship.friend_id)
    destroy_friendship(@friend)
    respond_to do |format|
      format.html do
        redirect_to user_path(@friend)
      end
      format.js do
        render :update do |page|
          page.remove 'remove_link'
        end
      end
    end
  end

  def pending
    @friends_pending = @user.friends_pending.paginate({:page => params[:page], :per_page => 10})
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
