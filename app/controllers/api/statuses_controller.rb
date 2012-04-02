module Api
  class StatusesController < Api::ApiController
  
    def show
      @status = Status.find(params[:id])

      respond_with(:api, @status)
    end

    def create
      if params[:user_id]
        @status = create_on_user
      elsif params[:lecture_id]
        @status = create_on_lecture
      else
        @status = create_on_space
      end
      @status.user = current_user

      if @status.valid?
        respond_with(:api, @status, :location => api_status_url(@status))
      else
        respond_with(:api, @status)
      end
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
    
    protected
    
    def create_on_user
      Activity.create(params[:status]) do |e|
        e.statusable = User.find(params[:user_id])
      end
    end
    
    protected
    
    def create_on_space
      Activity.create(params[:status]) do |e|
        e.statusable = Space.find(params[:space_id])
      end
    end
    
    protected
    
    def create_on_lecture
      if params[:status][:type] == "Help" or params[:status][:type] == "help"
        Help.create(params[:status]) do |e|
          e.statusable = Lecture.find(params[:lecture_id])
        end
      else
        Activity.create(params[:status]) do |e|
          e.statusable = Lecture.find(params[:lecture_id])
        end      
      end
    end

  end
end
