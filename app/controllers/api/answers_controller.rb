# -*- encoding : utf-8 -*-
module Api
  class AnswersController < Api::ApiController
    def index
      status = Status.find(params[:status_id])
      authorize! :read, status
      answers = status.answers

      respond_with(:api, answers)
    end

    def create
      status = Status.find(params[:status_id])
      authorize! :read, status

      answer = status.respond(params[:status], current_user) do |a|
        authorize! :manage, a
      end

      if answer.save
        respond_with(:api, answer, location: api_status_url(answer))
      else
        respond_with(:api, answer)
      end
    end

  end
end
