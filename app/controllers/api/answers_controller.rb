module Api
  class AnswersController < Api::ApiController
    def index
      @activity = Activity.find(params[:status_id])
      @answers = @activity.answers

      respond_with(:api, @answers)
    end

    def create
      @status = Status.new(params[:status]) do |e|
        e.user = current_user
      end

      @status.save

      respond_with(:api, @status)
    end
  end
end
