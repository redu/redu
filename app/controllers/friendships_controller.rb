# -*- encoding : utf-8 -*-
class FriendshipsController < BaseController
  include InvitationsProcessor

  load_and_authorize_resource :user, :find_by => :login
  load_and_authorize_resource :friendship, :through => :user

  def index
    @profile = params[:profile] if params.has_key? :profile

    # Diferencia a tela de meus contatos com a tela de contatos do perfil.
    if @profile
      if current_user == @user
        @contacts = @user.friends.page(params[:page]).per(8)
      else
        @contacts = Kaminari::paginate_array(@user.friends_not_in_common_with(current_user)).
          page(params[:page]).per(4)
      end
    else
      @total_friends = @user.friends.count
    end

    @friends = @user.friends.order(('first_name ASC')).
      includes(:friends, :experiences).page(params[:page]).per(20)

    respond_to do |format|
      format.html { render layout: 'new_application' }
    end
  end

  def new
    @invitations = @user.invitations
    @friendship_requests = @user.friendships.requested

    respond_to do |format|
      format.html { render :layout => 'new_application' }
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
        @in_search = params.has_key? :in_search
        @in_search_send = params.has_key? :in_search_send
        @in_search_accept = params.has_key? :in_search_accept
      end
    end
  end

  def destroy
    @friend = User.find(@friendship.friend_id)
    @user.destroy_friendship_with(@friend)
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
    UserNotifier.delay(:queue => 'email').
      friendship_requested(user, friend)
    respond_to do |format|
      format.js do
        @invited = friend.display_name
        @invitation_id = "friendship-request-for-#{friend.id}"
        render 'invitations/resend_email'
      end
    end
  end
end
