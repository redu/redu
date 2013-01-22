module Api
  class FoldersController < Api::ApiController
    def show
      folder = Folder.find(params[:id])
      authorize! :read, folder

      respond_with folder
    end

    # GET /api/folders/:folder_id/folders
    # GET /api/spaces/:space_id/folders
    def index
      context = context(params)
      authorize! :read, context

      folders = context.folders

      respond_with folders
    end

    protected

    def context(parameters)
      if parameters.has_key?(:folder_id)
        Folder.find(parameters[:folder_id])
      else #space_id
        Space.find(parameters[:space_id])
      end
    end
  end
end
