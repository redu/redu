module Api
  class AnswersController < Api::ApiController
    def index
      @status = Status.find(params[:status_id])

      if @status.is_a?(Activity) || @status.is_a?(Help)
        @answer = @status.answers
      end

      respond_with(:api, @answers)
    end

    def create
        @status = Status.find(params[:status_id])
        @answer = Answer.new(params[:status]) do |e|
          e.statusable = @status
          e.in_response_to = @status
          e.user = current_user
        end
        @answer.save

      if @answer.valid?
        respond_with(:api, @answer, :location => api_status_url(@answer))
      else
        respond_with(:api, @answer)
      end
    end

  end
end
