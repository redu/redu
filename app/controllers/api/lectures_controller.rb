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
      authorize! :manage, @subject
      lectureable, lec_features = lectureable_type(params.slice(:lecture))

      @lecture = @subject.lectures.create(lec_features[:lecture]) do |l|
        l.lectureable = lectureable
        l.owner = current_user
        l.subject = @subject
      end

      respond_with(:api, @lecture)
    end

    def destroy
      lecture = Lecture.find(params[:id])
      authorize! :manage, lecture
      lecture.destroy
      respond_with(:api, lecture)
    end

    protected

    def lectureable_type(param)
      case param[:lecture][:type].try(:downcase)
      when 'page'
        page_body = { :body => param[:lecture].delete(:body) }
        Page.create(page_body), param
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
