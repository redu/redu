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

      builder = case params[:lecture][:type]
      when 'Canvas'
        CanvasService.new(:access_token => current_access_token)
      when 'Document'
        DocumentService.new
      when 'Media'
        SeminarService.new
      end

      lecture = Lecture.new do |l|
        l.name = params[:lecture][:name]
        l.position = params[:lecture][:position]
        l.owner = current_user
        l.subject = subject
        l.lectureable = builder ? builder.create(params[:lecture]) : nil
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
  end
end
