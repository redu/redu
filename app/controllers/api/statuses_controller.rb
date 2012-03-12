module Api
  class StatusesController < Api::ApiController
    def show
      @status = Status.find(params[:id])

      respond_with @status, :with_representer => StatusRepresenter
    end
  end
end
