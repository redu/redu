class CanvasController < BaseController
  respond_to :html

  def show
    @space = Space.find(params[:space_id])
    @canvas = @space.canvas.first(:conditions => { :id => params[:id] })
    authorize! :read, @canvas
    @client_application = @canvas.client_application

    respond_with(@canvas)
  end
end
