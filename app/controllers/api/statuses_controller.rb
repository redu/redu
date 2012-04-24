module Api
  class StatusesController < Api::ApiController

    def show
      @status = Status.find(params[:id])
      authorize! :read, @status

      respond_with(:api, @status)
    end

    def create
      @values = { 'parametros' => params }
      if @values['parametros'][:status][:type] == "help" || 
        @values['parametros'][:status][:type] == "Help"
        if @values['parametros'][:lecture_id]
          @new_status = Help.new(@values['parametros'][:status])
        end
      else
        @new_status = Activity.new(@values['parametros'][:status])
      end

      @status = create_on
      if @status
        authorize! :create, @status
        @new_status.save
      end

      if @new_status.valid?
        respond_with(:api, @new_status, :location => api_status_url(@new_status))
      else
        respond_with(:api, @new_status)
      end
    end

    def index
      @values = { 'parametros' => params }
      who = statuses
      authorize! :read, who
      if who.class.to_s == "User"
        @statuses = Status.where(:user_id => who)
      else
        @statuses = Status.where(:statusable_id => who)
      end

      case @values['parametros'][:type]
      when 'help'
        @statuses = @statuses.where(:type => 'Help')
      when 'log'
        @statuses = @statuses.where(:type => 'Log')
      when 'activity'
        @statuses = @statuses.where(:type => 'Activity')
      else
        @statuses = @statuses.where(:type => ['Help', 'Activity'])
      end

      respond_with(:api, @statuses)
    end

    def destroy
      @status = Status.find(params[:id])
      authorize! :destroy, @status
      @status.destroy

      respond_with(:api, @status)
    end

    def timeline
      if params[:space_id]
        authorize! :read, Space.find(params[:space_id])
        @statuses = Status.from_hierarchy( Space.find(params[:space_id]) )
      else
        authorize! :read, User.find(params[:user_id])
        @statuses = User.find(params[:user_id]).overview
      end

      respond_with(:api, @statuses)
    end

    protected

    def statuses
      if @values['parametros'][:space_id]
        Space.find(@values['parametros'][:space_id])
      elsif @values['parametros'][:lecture_id]
        Lecture.find(@values['parametros'][:lecture_id])
      else
        User.find(@values['parametros'][:user_id])
      end
    end

    def create_on
      if @values['parametros'][:user_id]
        @new_status.statusable = User.find(@values['parametros'][:user_id])
      elsif @values['parametros'][:space_id]
        @new_status.statusable = Space.find(@values['parametros'][:space_id])
      else
        @new_status.statusable = Lecture.find(@values['parametros'][:lecture_id])
      end
      @new_status.user = current_user
    end

  end
end
