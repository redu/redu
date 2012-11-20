module Api
  class SubjectsController < Api::ApiController

    # GET /api/spaces/:space_id/subjects
    def index
      space = Space.find(params[:space_id])
      authorize! :read, space
      subjects = space.try(:subjects) || []
      respond_with(:api, subjects)
    end

    def show
      subject = Subject.find(params[:id])
      authorize! :read, subject
      respond_with(subject)
    end

    def destroy
      subject = Subject.find(params[:id])
      authorize! :destroy, subject
      subject.destroy
      respond_with(subject)
    end

    def create
      space = Space.find(params[:space_id])
      subject = Subject.new(params[:subject]) do |s|
        s.owner = current_user
        s.space = space
      end

      authorize! :create, subject
      subject.finalized = true
      subject.save

      respond_with :api, subject
    end

  end
end
