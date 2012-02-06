module Api
  class EnvironmentsController < ApiController
    respond_to :json

    def show
      @environment = Environment.find(params[:id])
      @environment.extend(EnvironmentRepresenter)

      respond_with @environment
    end

    def index
      @environments = Environment.all
      @environments.collect { |e| e.extend(EnvironmentRepresenter) }

      respond_with @environments
    end

    def destroy
      @environment = Environment.find(params[:id])
      @environment.extend(EnvironmentRepresenter)

      @environment.destroy

      respond_with @environment, :status => 200
    end

    def create
      @environment = Environment.new(params[:environment]) do |e|
        e.owner = current_user
        debugger
      end
      @environment.extend(EnvironmentRepresenter)

      if @environment.save
        respond_with @environment
      else
        respond_with @environment, :status => 400
      end

    end
  end
end
