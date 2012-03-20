module Api
  class StatusesController < Api::ApiController
    def show
      @status = Status.find(params[:id])
      @status.extend(ActivityRepresenter)

      respond_with(:api, @status)
    end
    
    def index
      @statuses = statuses
      
      case params[:type]
      when 'help'
        @statuses = @statuses.where(:type => 'Help')
      when 'log'
        @statuses = @statuses.where(:type => 'Log')
      when 'activity'
        @statuses = @statuses.where(:type => 'Activity')
      end

      respond_with(:api, @statuses)
    end
    
    protected
    
    def statuses
      if  params[:space_id]
        Status.where(:statusable_id => Space.find(params[:space_id]))
        
      elsif params[:lecture_id]
        Status.where(:statusable_id => Lecture.find(params[:lecture_id]))
        
      else
          Status.where(:user_id => User.find(params[:user_id]))
      end
    end
    
  end
end
