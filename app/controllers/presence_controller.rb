class PresenceController < ApplicationController

  def auth
    if current_user

      if params[:channel_name] == current_user.get_channel
        payload = { :friends => Presence.
                         list_of_channels(current_user) }

      else
        payload = { :name => current_user.display_name,
          :thumbnail => current_user.avatar.url(:thumb_32),
          :channel => current_user.get_channel }
      end

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
