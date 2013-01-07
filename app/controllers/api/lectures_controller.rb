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
        l.lectureable = create_lectureable(params[:lecture][:lectureable],
                                           params[:lecture][:type])
      end

      authorize! :manage, lecture
      lecture.save
      respond_with :api, lecture
    end

    protected

    def create_lectureable(lectureable, type)
      if type == "Canvas"
        c_app_id = lectureable[:client_application_id]
        canvas = Api::Canvas.create(:user_id => current_user.id,
                                    :client_application_id => c_app_id)
      end
    end
  end
end
