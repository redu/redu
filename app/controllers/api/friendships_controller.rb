module Api
  class FriendshipsController < Api::ApiController
    def index
      user = User.find(params[:user_id])
      authorize! :read, user

      friendships = user.friendships

      # Filtra resultados
      if params.has_key?(:status)
        friendships = friendships.where(:status => params[:status].to_s)
      end

      respond_with(:api, friendships)
    end

    def show
      friendship = Friendship.find(params[:id])
      authorize! :read, friendship

      respond_with(:api, friendship)
    end

    def create
      user = User.find(params[:user_id])
      authorize! :manage, user

      friend = User.find(params[:connection][:contact_id])
      friendship = user.friendship_for(friend)

      # Cria uma nova amizade
      if friendship.nil?
        friendship = user.be_friends_with(friend).first
        opts = { :location => api_friendship_url(friendship) }
      else
        opts = { :status => :see_other,
                 :location => { :url => api_friendship_url(friendship),
                                :method => :put } }
      end

      respond_with(:api, friendship, opts)
    end

    def update
      friendship = Friendship.find(params[:id])
      authorize! :manage, friendship

      # Aceita pedido de amizade
      if friendship.pending?
        friendship = friendship.user.be_friends_with(friendship.friend).first
        opts = { :location => api_friendship_url(friendship) }
      else
        opts = { :status => :see_other,
                 :location => { :url => api_friendship_url(friendship),
                                :method => :put } }
      end

      respond_with(:api, friendship, opts)
    end

    def destroy
      friendship = Friendship.find(params[:id])
      authorize! :manage, friendship

      friendship.user.destroy_friendship_with(friendship.friend)

      respond_with(:api, friendship)
    end
  end
end
