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
  end
end
