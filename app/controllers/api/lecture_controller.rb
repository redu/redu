module Api
  class LecturesController < ApiController
    def show
      @lecture = Lecture.find(params[:id])
      respond_with @lecture
    end
  end
end
