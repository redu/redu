module Api
  class EnvironmentsController < ApiController
    respond_to :json

    def show
      @environment = Envrionment.find(params[:id])
      @environment.extend(EnvironmentRepresenter)

      respond_with @environment
    end
  end
end
