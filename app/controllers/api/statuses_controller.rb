module Api
  class StatusesController < Api::ApiController

    def show
      @status = Status.find(params[:id])

      respond_with(:api, @status)
    end

    def create
      @values = params
      if params[:lecture_id]
        @status = create_on_lecture
      else
        @status = create_activity
      end

      if @status.valid?
        respond_with(:api, @status, :location => api_status_url(@status))
      else
        respond_with(:api, @status)
      end
    end

    def index
      @values = params
      @statuses = statuses

      case @values[:type]
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
      @status.destroy

      respond_with(:api, @status)
    end

    protected

    #FIXME se vc notar, o padRão onde vc faz case..when está se repetindo nesses
    # métodos protected.
    # Não seria mais interessante ter um método que faz o find do statusable
    # e os métodos create_activity, create_on_lecture e statuses usassem ele?
    # EX:
    # def statusable(params)
    #  if params[:space_id]
    #    Status.where(:statusable_id => Space.find(@values[:space_id]))
    #  elsif params[:lecture_id]
    #    Status.where(:statusable_id => Lecture.find(@values[:lecture_id]))
    #  else
    #    Status.where(:user_id => User.find(@values[:user_id]))
    #  end
    # end

    #FIXME esse método está confiando numa variável global! Se vc quiser usar
    # os params dentro dele, passa o valor como parâmentro (ex def statuses(params))
    def statuses
      if  @values[:space_id]
        Status.where(:statusable_id => Space.find(@values[:space_id]))
      elsif params[:lecture_id]
        Status.where(:statusable_id => Lecture.find(@values[:lecture_id]))
      else
        Status.where(:user_id => User.find(@values[:user_id]))
      end
    end

    #FIXME esse método está confiando numa variável global! Se vc quiser usar
    # os params dentro dele, passa o valor como parâmentro (ex def statuses(params))
    def create_activity
      Activity.create(@values[:status]) do |e|
        if @values[:user_id]
          e.statusable = User.find(@values[:user_id])
        elsif @values[:space_id]
          e.statusable = Space.find(@values[:space_id])
        else
          e.statusable = Lecture.find(@values[:lecture_id])
        end
        e.user = current_user
      end
    end

    #FIXME esse método está confiando numa variável global! Se vc quiser usar
    # os params dentro dele, passa o valor como parâmentro (ex def statuses(params))
    def create_on_lecture
      if @values[:status][:type] == "help" || @values[:status][:type] == "Help"
        Help.create(@values[:status]) do |e|
          e.statusable = Lecture.find(@values[:lecture_id])
          e.user = current_user
        end
      else
        create_activity
      end
    end

  end
end
