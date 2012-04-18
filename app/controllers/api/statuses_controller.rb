module Api
  class StatusesController < Api::ApiController
    def show
      @status = Status.find(params[:id])
      authorize! :read, @status

      respond_with @status, :with_representer => StatusRepresenter
    end
  end
end
