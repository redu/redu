module Api
  class CanvasController < Api::ApiController
    represents :json, :collection => RawCanvasCollectionRepresenter,
      :entity => RawCanvasRepresenter

    # GET /api/canvas/:id
    def show
      canvas = Canvas.find(params[:id])
      authorize! :read, canvas.container

      respond_with(canvas)
    end

    # POST /api/spaces/:id/canvas
    def create
      space = Space.find(params[:space_id])

      authorize! :manage, space

      canvas_builder = CanvasService.new(:access_token => current_access_token)
      canvas = canvas_builder.create(params[:canvas]) do |c|
        c.container = space
      end

      if canvas.valid?
        respond_with(canvas)
      else
        respond_with(:api, canvas)
      end
    end

    # DELETE /api/canvas/:id
    def destroy
      canvas = Canvas.find(params[:id])
      authorize! :manage, canvas.container

      canvas.destroy

      respond_with(canvas)
    end

    def index
      space = Space.find(params[:space_id])
      authorize! :read, space

      canvas = space.canvas
      respond_with(canvas)
    end
  end
end
