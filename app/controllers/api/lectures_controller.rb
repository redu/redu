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
      lectureable, params_lecture = lectureable_type(params)

      @lecture = @subject.lectures.create(params_lecture[:lecture]) do |l|
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
        params_page = { :body => param[:lecture].delete(:body) }
        lectureable = Page.new(params_page), param
      when 'seminar'
        params_seminar = { :external_resource_type => 
                                            validate_url(param[:lecture][:url]),
                             :external_resource => param[:lecture].delete(:url),
                   :original_file_name => param[:lecture].delete(:media_title) }

        lectureable = Seminar.new(params_seminar), param
      end
    end

    def validate_url(url)
      'youtube' if url.
               scan(/youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/)[0]
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
