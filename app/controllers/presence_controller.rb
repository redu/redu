class PresenceController < BaseController
  authorize_resource :user
  authorize_resource :presence, :through => :user

  rescue_from CanCan::AccessDenied do |exception|
    render :text => "Não autorizado", :status => '403'
  end

  def auth
    if params[:channel_name].include? "presence"
      presence
    else
      render :text => "Não autorizado.", :status => '403'
    end
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
        :channel => current_user.presence_channel,
        :roles => Presence.fill_roles(current_user) }

      if !channels.select{|v| v.has_value? params[:channel_name] }.empty?
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

  def private

  end
end
