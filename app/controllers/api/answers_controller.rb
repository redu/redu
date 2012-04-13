module Api
  class AnswersController < Api::ApiController
    def index
      @status = Status.find(params[:status_id])

      if @status.is_a?(Activity) || @status.is_a?(Help)
        @answer = @status.answers #FIXME erro de digitação. Como é que o teste disso passou?
      end

      respond_with(:api, @answers) #FIXME @answers não existe!
    end

    def create #FIXME o contedúdo desse método está com a indentação incorreta
        @status = Status.find(params[:status_id])
        @answer = Answer.new(params[:status]) do |e|
          e.statusable = @status
          e.in_response_to = @status
          e.user = current_user
        end
        @answer.save # FIXME pq não chamar create e eliminar essa linha?

        # FIXME mais elegante:
        # @status = Status.find(params[:status_id])
        # @answer = @status.answers.create(params[:status]) do |e|
        #   e.statusable = @status
        #   e.user = current_user
        # end

      if @answer.valid?
        respond_with(:api, @answer, :location => api_status_url(@answer))
      else
        respond_with(:api, @answer)
      end
    end

  end
end
