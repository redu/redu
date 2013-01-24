module Api
  class LecturesController < Api::ApiController
    include Api::RepresenterInflector

    def show
      lecture = Lecture.find(params[:id])
      authorize! :read, lecture

      klass = representer_for_resource(lecture.lectureable) || LectureRepresenter
      respond_with lecture, :represent_with => klass
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

      if enrollment = current_user.get_association_with(lecture)
        lecture.create_asset_report(:enrollments => [enrollment])
      end

      opts = if lecture.valid?
        klass = representer_for_resource(lecture.lectureable) || LectureRepresenter
        { :represent_with => klass }
      else
        {}
      end

      respond_with :api, lecture, opts
    end

    def index
      conds = { :id => params[:subject_id], :finalized => true }
      subject = Subject.first(:conditions => conds)
      authorize! :read, subject

      lectures = subject.lectures.includes(:lectureable)

      respond_with :api, lectures do |format|
        format.json do
          render :json => lectures.extend(LecturesRepresenter)
        end
      end
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
