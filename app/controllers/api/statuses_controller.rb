module Api
  class StatusesController < Api::ApiController

    def show
      status = Status.find(params[:id])

      respond_with(:api, status)
    end

    def create
      status = Status.new(params[:status]) do |s|
        s.statusable = context(params)
        s.user = current_user
        s.type = params[:status].fetch(:type, 'Activity').camelize
      end

      # Transformando numa instancia do filho do sti
      status = status.becomes(status.type.constantize)

      if status.save
        respond_with(:api, status, :location => api_status_url(status))
      else
        respond_with(:api, status)
      end
    end

    def index
      statuses = statuses(params)

      statuses = case params[:type]
      when 'help'
        statuses.where(:type => 'Help')
      when 'log'
        statuses.where(:type => 'Log')
      when 'activity'
        statuses.where(:type => 'Activity')
      else
        statuses.where(:type => ['Help', 'Activity'])
      end

      respond_with(:api, statuses)
    end

    def destroy
      status = Status.find(params[:id])
      status.destroy

      respond_with(:api, status)
    end

    def timeline
      statusable = context(params)
      statuses = if statusable.is_a?(Space)
        Status.from_hierarchy(statusable)
      else
        statusable.overview
      end

      respond_with(:api, statuses)
    end

    protected

    def context(params)
      if params[:space_id]
        Space.find(params[:space_id])
      elsif params[:lecture_id]
        Lecture.find(params[:lecture_id])
      else
        User.find(params[:user_id])
      end
    end

    def statuses(params)
      statusable = context(params)

      if statusable.is_a? User
        Status.where(:user_id => statusable)
      else
        Status.where(:statusable_id => statusable,
                     :statusable_type => statusable.class.to_s)
      end
    end
  end
end
