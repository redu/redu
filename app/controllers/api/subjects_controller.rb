module Api
  class SubjectsController < Api::ApiController
    
    # GET /api/spaces/:space_id/subjects
    def index
      @space = Space.find(params[:space_id])
      @subjects = @space.try(:subjects) || []

      respond_with (:api, @space, @subjects)
    end

  end
end
