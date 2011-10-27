class PresenceController < BaseController
  authorize_resource :user
  authorize_resource :presence, :through => :user

  rescue_from CanCan::AccessDenied do |exception|
    render :text => "Não autorizado", :status => '403'
  end

  def auth
    if params[:channel_name].include? "presence"
      response_body = presence_auth(params[:channel_name], current_user,
                                    params[:socket_id])

      render :json => response_body
    elsif params[:channel_name].include? "private"
      response_body = private_auth(params[:channel_name], current_user,
                                   params[:socket_id])
      render :json => response_body
    else
      render :text => "Não autorizado.", :status => '403'
    end
  end

  def multiauth
    response_body = params[:channels].collect do |ch|
      payload = case
      when ch.include?('presence')
        begin
          presence_auth(ch, current_user, params[:socket_id])
        rescue CanCan::AccessDenied
          next
        end
      when ch.include?('private')
        begin
          private_auth(ch, current_user, params[:socket_id])
        rescue CanCan::AccessDenied
          next
        end
      else
        next
      end

      { ch => prepare_for_multiauth(payload, ch) }
    end

    render :json => response_body.inject({}) { |acc,hash| acc.merge(hash) }
  end

  def send_chat_message
    contact = User.find(params[:contact_id].to_i)
    private_channel = current_user.private_channel_with(contact)

    time = Time.zone.now.strftime('hoje, %H:%M')
    payload = { :thumbnail => current_user.avatar.url(:thumb_24),
      :text => params[:text], :time => time,
      :name => current_user.display_name,
      :user_id => current_user.id }

    begin
      Pusher[private_channel].trigger!('message_sent', payload)
      json_response = { :status => 200, :time => time }
    rescue Pusher::Error => e
      json_response = { :status => 500 }
    end

    ChatMessage.create(:user => current_user, :contact => contact,
                       :message => params[:text])

    render :json => json_response
  end

  def last_messages_with
    contact = User.find(params[:contact_id].to_i)
    json_response = ChatMessage.log(current_user, contact)
    render :json => json_response
  end

  protected

  # Autentica usuário no canal de presença. Retorna o payload para ser
  # enviado ao cliente ou nil para caso de acesso negado.
  def presence_auth(channel_name, user, socket_id)
    channels = Presence.list_of_channels(user)
    if channel_name == user.presence_channel
      payload = { :contacts => channels }

      response_body = Pusher[channel_name].
        authenticate(socket_id,
                     :user_id => user.id,
                     :user_info => payload )

      return response_body.stringify_keys!
    else
      authorize! :subscribe_channel, contact(channel_name)

      payload = { :name => user.display_name,
        :thumbnail => user.avatar.url(:thumb_24),
        :pre_channel => user.presence_channel,
        :pri_channel => user.private_channel_with(contact(channel_name)),
        :roles => Presence.fill_roles(user) }

      response_body = Pusher[channel_name].
        authenticate(socket_id,
                     :user_id => user.id,
                     :user_info => payload )

      return response_body.stringify_keys!
    end
  end

  # Autentica usuário no canal de privado. Retorna o payload para ser
  # enviado ao cliente ou nil para caso de acesso negado.
  def private_auth(channel_name, user, socket_id)
    ids = /^private-(\d+)-(\d+)/.match(channel_name)
    # Verificação se o usuário e o contato estão no canal
    if user.id == ids[1].to_i
      contact_user = User.find(ids[2])
      authorize! :subscribe_channel, contact_user
    elsif user.id == ids[2].to_i
      contact_user = User.find(ids[1])
      authorize! :subscribe_channel, contact_user
    else
      raise CanCan::AccessDenied.new("Não autorizado", :auth, Presence)
    end

    response_body = Pusher[channel_name].
      authenticate(socket_id)

    return response_body
  end

  # Usuário dono do canal de presença ao qual estou me inscrevendo
  def contact(channel)
    # Pegar id do nome do canal
    contact_id = /^presence-user-(\d+)$/.match(channel)[1]
    User.find(contact_id)
  end

  # Transforma uma resposta de autenticação no formato apropriado para
  # autenticação multipla (adiciona channel_name)
  def prepare_for_multiauth(common_response, channel_name)
    common_response['channel_name'] = channel_name
    common_response
  end
end
