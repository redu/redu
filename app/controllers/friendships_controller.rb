class FriendshipsController < BaseController

  load_and_authorize_resource :user
  authorize_resource :friendship, :through => :user

  def index
    @friends = @user.friends.paginate( {:page => params[:page], :per_page => 10 } )
  end

  def create
    current_user.be_friends_with(@user)
    respond_to do |format|
      format.html do
        redirect_to user_path(@user)
      end
      format.js do
        render :update do |page|
          if current_user.friends? @user
          page.insert_html :after, 'follow_link',
           'É seu amigo'
          else
          page.insert_html :after, 'follow_link',
            (link_to 'Aguardando aceitação', nil, :class => 'waiting')
          end
          page.remove 'follow_link'
        end
      end
    end
  end

  def destroy
    destroy_friendship(@user)
    respond_to do |format|
      format.html do
        redirect_to user_path(@user)
      end
    end
  end

  def pending
    authorize! :manage, @user
    @friends_pending = @user.friends_pending.paginate({:page => params[:page], :per_page => 10})
  end

  def accept
    authorize! :manage, @user
    @choosen_friend = User.find_by_id(params[:id])
    current_user.be_friends_with(@choosen_friend)
    respond_to do |format|
      format.html do
        redirect_to pending_user_friendships_path(current_user)
      end
      format.js
    end
  end

  def decline
    authorize! :manage, @user
    choosen_friend = User.find_by_id(params[:id])
    destroy_friendship(choosen_friend)
    respond_to do |format|
      format.html do
        redirect_to pending_user_friendships_path(current_user)
      end
      format.js
    end
  end

  protected
  def destroy_friendship(choosen_user)
    friendship_in = current_user.friendship_for(choosen_user)
    friendship_out = choosen_user.friendship_for(current_user)
    friendship_in.destroy
    friendship_out.destroy
  end

end
