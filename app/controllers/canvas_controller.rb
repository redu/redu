class CanvasController < BaseController
  respond_to :html

  def show
    content_for :nav_global_context, "spaces"

    @space = Space.find(params[:space_id])
    @canvas = @space.canvas.first(:conditions => { :id => params[:id] })
    authorize! :read, @canvas
    @client_application = @canvas.client_application

    respond_with(@canvas)
  end
end
