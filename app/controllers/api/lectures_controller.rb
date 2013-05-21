# -*- encoding : utf-8 -*-
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
      authorize! :manage, subject

      options = { :access_token => current_access_token }.merge(params[:lecture])
      service = LectureService.new(current_ability, options)
      lecture = service.create do |lecture|
        lecture.owner = current_user
        lecture.subject = subject
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

    def destroy
      lecture = Lecture.find(params[:id])
      authorize! :manage, lecture

      lecture.destroy

      respond_with :api, lecture
    end
  end
end
