module Api
  class StatusesController < Api::ApiController

    def show
      @status = Status.find(params[:id])

      respond_with(:api, @status)
    end

    def create
      if params[:lecture_id]
        @status = create_on_lecture
      else
        @status = create_activity
      end
      # FIXME isso é necessário? Vc pq não usar o create ao invés do new dentro dos métodos create_activity e create_on_lecture
      @status.save

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
      else
        # FIXME sintaxe mais elegante:
        # @statuses = @statuses.where(:type => ['Help', 'Activity'])
        @statuses = @statuses.where("type LIKE 'Help' OR type LIKE 'Activity'")
      end

      respond_with(:api, @statuses)
    end

    def destroy
      @status = Status.find(params[:id])
      @status.destroy

      respond_with(:api, @status)
    end

    protected

    # FIXME não é bom confiar em variáveis globais (params). Passa o que vc precisa como parametro.
    def statuses
      if  params[:space_id]
        Status.where(:statusable_id => Space.find(params[:space_id]))
      elsif params[:lecture_id]
        Status.where(:statusable_id => Lecture.find(params[:lecture_id]))
      else
        Status.where(:user_id => User.find(params[:user_id]))
      end
    end

    # FIXME não é bom confiar em variáveis globais (params). Passa o que vc precisa como parametro.
    def create_activity
      Activity.new(params[:status]) do |e|
        if params[:user_id]
          e.statusable = User.find(params[:user_id])
        elsif params[:space_id]
          e.statusable = Space.find(params[:space_id])
        else
          e.statusable = Lecture.find(params[:lecture_id])
        end
        e.user = current_user
      end
    end

    # FIXME não é bom confiar em variáveis globais (params). Passa o que vc precisa como parametro.
    def create_on_lecture
      if params[:status][:type] == "help" || params[:status][:type] == "Help"
        Help.create(params[:status]) do |e|
          e.statusable = Lecture.find(params[:lecture_id])
          e.user = current_user
        end
      else
        create_activity
      end
    end

  end
end
