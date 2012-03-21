module Api
  class AnswersController < Api::ApiController
    def index
      
      @activity = Activity.find(params[:status_id])
      @answers = @activity.answers
#      debugger
      
      respond_with(:api, @answers)
    end
  end
end
