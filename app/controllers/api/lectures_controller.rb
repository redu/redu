module Api
  class LecturesController < Api::ApiController
    def show
      lecture = Lecture.find(params[:id])
      authorize! :read, lecture
      respond_with lecture
    end

    def create
      subject = Subject.find(params[:subject_id])
      lecture = Lecture.new do |l|
        l.name = params[:lecture][:name]
        l.owner = current_user
        l.subject = subject
        l.lectureable = create_lectureable(params[:lecture])
      end

      authorize! :manage, lecture
      lecture.save
      respond_with :api, lecture
    end

    protected

    def create_lectureable(lecture_attrs)
      case lecture_attrs[:type].try(:downcase)
      when "canvas"
        c_app_id = lecture_attrs[:lectureable][:client_application_id]
        attrs = {
          :user_id => current_user.id,
          :client_application_id => c_app_id,
        }
        if url = lecture_attrs[:lectureable][:current_url]
          attrs.merge!({:url => url})
        end

        canvas = Api::Canvas.create(attrs)
      end
    end
  end
end
