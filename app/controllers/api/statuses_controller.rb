module Api
  class StatusesController < Api::ApiController
    def show
      @status = Status.find(params[:id])
      @status.extend(ActivityRepresenter)

      respond_with(:api, @status)
    end
    
    def index
      @user = User.find(params[:user_id])
      @statuses = Status.where(:user_id => @user)
      
      case params[:type]      
      when 'help'
        @statuses = @statuses.where(:type => 'Help')
      when 'log'
        @statuses = @statuses.where(:type => 'Log')
      end

      respond_with(:api, @statuses)
    end
  end
end
