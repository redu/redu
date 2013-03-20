module Api
  class ConnectionsController < Api::ApiController
    def index
      user = User.find(params[:user_id])
      authorize! :read, user

      connections = user.friendships

      # Filtra resultados
      if params.has_key?(:status)
        connections = connections.where(:status => params[:status].to_s)
      end

      respond_with(:api, connections, :represent_with => ConnectionRepresenter)
    end

    def show
      connection = Friendship.find(params[:id])
      authorize! :read, connection

      respond_with(:api, connection, :represent_with => ConnectionRepresenter)
    end

    def create
      user = User.find(params[:user_id])
      authorize! :manage, user

      friend = User.find(params[:connection][:contact_id])
      connection = user.friendship_for(friend)

      # Cria uma nova amizade
      if connection.nil?
        connection = user.be_friends_with(friend).first

        respond_with(:api, connection,
                     :location => api_connection_url(connection),
                     :represent_with => ConnectionRepresenter)
      else
        respond_with(:api, connection, :status => :see_other,
                     :location => { :url => api_connection_url(connection),
                                    :method => :put },
                     :represent_with => ConnectionRepresenter)
      end
    end

    def update
      connection = Friendship.find(params[:id])
      authorize! :manage, connection

      # Aceita pedido de amizade
      if connection.pending?
        connection = connection.user.be_friends_with(connection.friend).first

        respond_with(:api, connection,
                     :location => api_connection_url(connection),
                     :represent_with => ConnectionRepresenter)
      else
        respond_with(:api, connection, :status => :see_other,
                     :location => { :url => api_connection_url(connection),
                                    :method => :put },
                     :represent_with => ConnectionRepresenter)
      end
    end

    def destroy
      connection = Friendship.find(params[:id])
      authorize! :manage, connection

      connection.user.destroy_friendship_with(connection.friend)

      respond_with(:api, connection, :represent_with => ConnectionRepresenter)
    end
  end
end
