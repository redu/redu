module Api
  class AnswersController < Api::ApiController
    def index
      @status = Status.find(params[:status_id])

      if @status.is_a? Activity
        @status = Activity.find(params[:status_id])
      else
        @status = Help.find(params[:status_id])
      end
      @answers = @status.answers # isso não é salvo

      #FIXME
      # Sugestão de refactoring:
      # if @status.is_a?(Activity) || @status.is_a?(Help)
      #   @answers = @status.answers
      # end
      respond_with(:api, @answers)
    end

    def create
        @status = Status.find(params[:status_id])
        if @status.is_a? Help
          create_on_help #FIXME não há necessidade de método auxiliar
        elsif @status.is_a? Activity
          create_on_activity #FIXME não há necessidade de método auxiliar
        else #FIXME não faz sentido criar um Answer sem estar associado a um Activity ou Help
          @answer = Answer.new(params[:status_id])
        end
        @answer.user = current_user # isso não é salvo

      # FIXME
      # Sugestão refactoring
      # if @status.is_a?(Activity) || @status.is_a?(Help)
      #   @statuse.answers.create(params) do
      #    # ...
      #   end
      # end

      if @answer.valid?
        respond_with(:api, @answer, :location => api_status_url(@answer))
      else
        respond_with(:api, @answer)
      end
    end

    protected

    def create_on_help
      @answer = Answer.create(params[:status]) do |e|
        @help = Help.find(params[:status_id])
        e.statusable = @help
        e.in_response_to = @help
      end
    end

    def create_on_activity
      @answer = Answer.create(params[:status]) do |e|
        @activity = Activity.find(params[:status_id])
        e.statusable = @activity
        e.in_response_to = @activity
      end
    end

  end
end
