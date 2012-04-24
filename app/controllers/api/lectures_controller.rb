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
      @lectures = lectures(@subject, params[:type])

      respond_with(@lectures)
    end

    protected

    def lectures(subject, type)
      case type.try(:downcase)
      when 'page'
        subject.lectures.where(:lectureable_type => 'Page')
      when 'seminar'
        subject.lectures.where(:lectureable_type => 'Seminar')
      when 'document'
        subject.lectures.where(:lectureable_type => 'Document')
      else
        subject.try(:lectures, [])
      end
    end
  end
end
