module Api
  class LecturesController < ApiController
    def show
      @lecture = Lecture.find(params[:id])
      authorize! :read, @lecture

      respond_with(:api, @lecture)
    end
  end
end
