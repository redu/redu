# -*- encoding : utf-8 -*-
module Api
  class EnvironmentsController < ApiController

    def show
      @environment = Environment.find(params[:id])
      authorize! :read, @environment

      respond_with @environment
    end

    def index
      authorize! :manage, current_user
      @environments = current_user.environments

      respond_with @environments
    end

    def destroy
      @environment = Environment.find(params[:id])
      authorize! :manage, @environment
      @environment.audit_billable_and_destroy

      respond_with @environment
    end

    def create
      authorize! :create, Environment
      @environment = Environment.new(params[:environment]) do |e|
        e.owner = current_user
      end
      @environment.save

      respond_with @environment
    end

    def update
      @environment = Environment.find(params[:id])
      authorize! :manage, @environment
      @environment.update_attributes(params[:environment])

      respond_with @environment
    end
  end
end
