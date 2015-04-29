# -*- encoding : utf-8 -*-
class CanvasController < BaseController
  respond_to :html

  def show
    @space = Space.find(params[:space_id])
    @canvas = @space.canvas.first(:conditions => { :id => params[:id] })
    authorize! :read, @canvas
    @client_application = @canvas.client_application

    options = { :redu_space_id => @space.id, :redu_container => :space,
                :redu_user_id => current_user.id }
    @canvas_url = @canvas.current_url(options)

    respond_with(@canvas, layout: 'new_application')
  end
end
