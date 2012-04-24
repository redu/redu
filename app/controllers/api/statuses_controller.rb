module Api
  class StatusesController < Api::ApiController

    def show
      status = Status.find(params[:id])

      respond_with(:api, status)
    end

    def create
      if params[:status][:type] == "help" || 
        params[:status][:type] == "Help"
        if params[:lecture_id]
          new_status = Help.new(params[:status])
        end
      else
        new_status = Activity.new(params[:status])
      end
      new_status.user = current_user
      new_status.statusable = statuses(params)

      if new_status.statusable
        new_status.save
      end

      if new_status.valid?
        respond_with(:api, new_status, :location => api_status_url(new_status))
      else
        respond_with(:api, new_status)
      end
    end

    def index
      statuses = who(params)
      case params[:type]
      when 'help'
        statuses = statuses.where(:type => 'Help')
      when 'log'
        statuses = statuses.where(:type => 'Log')
      when 'activity'
        statuses = statuses.where(:type => 'Activity')
      else
        statuses = statuses.where(:type => ['Help', 'Activity'])
      end
      respond_with(:api, statuses)
    end

    def destroy
      status = Status.find(params[:id])
      status.destroy

      respond_with(:api, status)
    end

    def timeline
      if params[:space_id]
        statuses = Status.from_hierarchy( Space.find(params[:space_id]) )
      else
        statuses = User.find(params[:user_id]).overview
      end

      respond_with(:api, statuses)
    end

    protected

    def statuses(params)
      if params[:space_id]
        Space.find(params[:space_id])
      elsif params[:lecture_id]
        Lecture.find(params[:lecture_id])
      else
        User.find(params[:user_id])
      end
    end

    def who(params)
      context = statuses(params)
      if context.class.to_s == "User"
        statuses = Status.where(:user_id => context)
      else
        statuses = Status.where(:statusable_id => context, 
          :statusable_type => context.class.to_s)
      end
    end

  end
end
