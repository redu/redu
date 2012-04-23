module Api
  class SubjectsController < Api::ApiController
    
    # GET /api/spaces/:space_id/subjects
    def index
      @space = Space.find(params[:space_id])
      @subjects = @space.try(:subjects) || []
      respond_with(:api, @subjects)
    end

    def show
      @subject = Subject.find(params[:id])
      respond_with(@subject)
    end

    def destroy
      @subject = Subject.find(params[:id])
      @subject.destroy
      respond_with(@subject)
    end

  end
end
