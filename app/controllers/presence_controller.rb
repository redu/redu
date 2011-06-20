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
    contact = User.find(params[:contact_id].to_i)
    private_channel = current_user.private_channel_with(contact)

    payload = { :thumbnail => current_user.avatar.url(:thumb_24),
      :text => params[:text], :time => Time.now,
      :name => current_user.display_name,
      :user_id => current_user.id }

    begin
      Pusher[private_channel].trigger!('message_sent', payload,
                                      params[:owner_socket_id])
      json_response = { :status => 200, :time => Time.now }
    rescue Pusher::Error => e
      json_response = { :status => 500 }
    end

    render :json => json_response
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
      authorize! :subscribe_channel, contact

      payload = { :name => current_user.display_name,
        :thumbnail => current_user.avatar.url(:thumb_24),
        :pre_channel => current_user.presence_channel,
        :pri_channel => current_user.private_channel_with(contact),
        :roles => Presence.fill_roles(current_user) }

      json_response = Pusher[params[:channel_name]].
        authenticate(params[:socket_id],
                     :user_id => current_user.id,
                     :user_info => payload )

      render :json => json_response
    end
  end

  def private_chat
    list_channels = params[:channel_name].split('-')
    # Verificação se o usuário e o contato estão no canal
    if current_user.id == list_channels[1].to_i
      contact_user = User.find(list_channels[2])
      authorize! :subscribe_channel, contact_user
    elsif current_user.id == list_channels[2].to_i
      contact_user = User.find(list_channels[1])
      authorize! :subscribe_channel, contact_user
    else
      raise CanCan::AccessDenied.new("Não autorizado", :auth, Presence)
    end

    if params[:log].nil?
      json_response = Pusher[params[:channel_name]].
        authenticate(params[:socket_id])

    else
      json_response = Pusher[params[:channel_name]].
        authenticate(params[:socket_id],
                    :logs => ChatMessage.log(current_user, contact_user,
                                                       1.day.ago, 20))
    end

    render :json => json_response
  end

  # Usuário dono do canal de presença ao qual estou me inscrevendo
  def contact
    # Pegar id do nome do canal
    contact_id = /^presence-user-(\d+)$/.match(params[:channel_name])[1]
    User.find(contact_id)
  end
end
