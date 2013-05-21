# -*- encoding : utf-8 -*-
class PresenceController < BaseController
  authorize_resource :user

  rescue_from CanCan::AccessDenied do |exception|
    render :text => "Não autorizado", :status => '403'
  end

  def auth
    @presence = Presence.new(current_user)

    auth_response = if params[:channel_name].include? "presence"
      @presence.presence_auth(params[:channel_name], params[:socket_id])
    elsif params[:channel_name].include? "private"
      @presence.private_auth(params[:channel_name], params[:socket_id])
    end

    if auth_response
      render :json => auth_response
    else
      raise CanCan::AccessDenied.new("Não autorizado", :auth, Presence)
    end
  end

  def multiauth
    @presence = Presence.new(current_user)

    response_body = params[:channels].collect do |ch|
      payload = case
      when ch.include?('presence')
        @presence.presence_auth(ch, params[:socket_id])
      when ch.include?('private')
        @presence.private_auth(ch, params[:socket_id])
      end

      next unless payload

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

  # Transforma uma resposta de autenticação no formato apropriado para
  # autenticação multipla (adiciona channel_name)
  def prepare_for_multiauth(common_response, channel_name)
    common_response['channel_name'] = channel_name
    common_response
  end
end
