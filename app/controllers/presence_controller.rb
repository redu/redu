class PresenceController < BaseController
  authorize_resource :user
  authorize_resource :presence, :through => :user

  rescue_from CanCan::AccessDenied do |exception|
    render :text => "Não autorizado", :status => '403'
  end

  def auth
    if params[:channel_name].include? "presence"
      presence
    elsif params[:channel_name].include? "private"
      private_chat
    else
      render :text => "Não autorizado.", :status => '403'
    end
  end

  def send_chat_message
    render :json => { :status => '200' }
  end

  protected
  def presence
    channels = Presence.list_of_channels(current_user)
    if params[:channel_name] == current_user.presence_channel
      payload = { :contacts => channels }

      json_response = Pusher[params[:channel_name]].
        authenticate(params[:socket_id],
                     :user_id => current_user.id,
                     :user_info => payload )

      render :json => json_response
    else
      payload = { :name => current_user.display_name,
        :thumbnail => current_user.avatar.url(:thumb_24),
        :pre_channel => current_user.presence_channel,
        :pri_channel => current_user.private_channel_with(contact),
        :roles => Presence.fill_roles(current_user) }

      unless channels.select{|v| v.has_value? params[:channel_name] }.empty?
        json_response = Pusher[params[:channel_name]].
          authenticate(params[:socket_id],
                       :user_id => current_user.id,
                       :user_info => payload )

        render :json => json_response
      else
        render :text => "Não autorizado", :status => '403'
      end
    end
  end

  def private_chat
    if params[:log].nil?
      json_response = Pusher[params[:channel_name]].
        authenticate(params[:socket_id])

      render :json => json_response
    else

      render :text => "Não autorizado", :status => '403'
    end
  end

  # Usuário dono do canal de presença ao qual estou me inscrevendo
  def contact
    # Pegar id do nome do canal
    contact_id = /^presence-user-(\d+)$/.match(params[:channel_name])[1]
    User.find(contact_id)
  end
end
