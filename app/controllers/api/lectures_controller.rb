module Api
  class LecturesController < ApiController
    def show
      @lecture = Lecture.find(params[:id])
      authorize! :read, :error

      respond_with(@lecture)
    end

    def index
      @subject = Subject.find(params[:subject_id])
      authorize! :read, :error
      @lectures = @subject.try(:lectures, [])

      respond_with(@lectures)
    end
  end
end
