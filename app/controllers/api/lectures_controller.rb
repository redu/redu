module Api
  class LecturesController < ApiController
    def show
      lecture = Lecture.find(params[:id])
      authorize! :read, lecture

      respond_with(:api, lecture)
    end

    def index
      subject = Subject.find(params[:subject_id])
      authorize! :read, subject
      lectures = lectures(subject, params[:type])

      respond_with(lectures)
    end

    def create
      subject = Subject.find(params[:subject_id])
      authorize! :manage, subject

      lecture = subject.lectures.create do |l|
        l.name = params[:lecture][:name]
        l.lectureable = lectureable(params)
        l.owner = current_user
        l.subject = subject
      end

      respond_with(:api, lecture)
    end

    def destroy
      lecture = Lecture.find(params[:id])
      authorize! :manage, lecture
      lecture.destroy
      respond_with(:api, lecture)
    end

    protected

    def lectureable(params)
      case params[:lecture][:type].try(:downcase)
      when 'page'
        create_page(params)
      when 'seminar'
        create_seminar(params)
      end
    end

    def validate_youtube(url)
      # Esperar a resolução do issue #837 para remover esse método.
      # Delegar validações para o modelo.
      'youtube' if url.
               scan(/youtube\.com\/watch\?v=([A-Za-z0-9._%-]*)[&\w;=\+_\-]*/)[0]
    end

    def create_page(params)
      Page.new({ :body => params[:lecture].delete(:body) }) 
    end

    def create_seminar(params)
      Seminar.new do |seminar|
        seminar.external_resource_type = validate_youtube(params[:lecture][:url])
        seminar.external_resource = params[:lecture][:url]
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
