module Api
  class EnvironmentsController < ApiController

    def show
      @environment = Environment.find(params[:id])

      respond_with @environment
    end

    def index
      user = current_user
      @environments = Environment.all

      respond_with @environments
    end

    def destroy
      @environment = Environment.find(params[:id])
      @environment.audit_billable_and_destroy

      respond_with @environment
    end

    def create
      @environment = Environment.new(params[:environment]) do |e|
        e.owner = current_user
      end
      @environment.save

      respond_with @environment
    end

    def update
      @environment = Environment.find(params[:id])
      @environment.update_attributes(params[:environment])

      respond_with @environment
    end
  end
end
