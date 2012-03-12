class FriendshipsController < BaseController

  load_and_authorize_resource :user, :find_by => :login
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

  def new
    @contacts_recommendations = @user.recommended_contacts(5)
    respond_to do |format|
      format.html
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

  protected
  def destroy_friendship(choosen_user)
    friendship_in = current_user.friendship_for(choosen_user)
    friendship_out = choosen_user.friendship_for(current_user)
    # FIXME só deletar se existir conexão
    friendship_in.destroy
    friendship_out.destroy
  end

end
