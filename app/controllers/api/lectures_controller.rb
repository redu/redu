module Api
  class LecturesController < ApiController
    def show
      @lecture = Lecture.find(params[:id])
      authorize! :read, @lecture

      respond_with(@lecture)
    end

    def index
      @subject = Subject.find(params[:subject_id])
      authorize! :read, @subject
      @lectures = lectures(@subject, params[:type])

      respond_with(@lectures)
    end

    def create
      @subject = Subject.find(params[:subject_id])
      authorize! :create, @subject
      lectureable = watershed(params[:lecture])

      @lecture = @subject.lectures.create(params[:lecture]) do |l|
        l.lectureable = lectureable
        l.owner = current_user
        l.subject = @subject
      end

      respond_with(:api, @lecture)
    end

    protected

    def watershed(param)
      case params[:lecture][:type].try(:downcase)
      when 'page'
        page_body = { :body => params[:lecture].delete(:body) }
        lectureable = Page.create page_body
      end
    end

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
