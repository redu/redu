# -*- encoding : utf-8 -*-
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

    def create
      folder = context(params)
      authorize! :manage, folder

      new_folder = folder.folders.create(params[:folder]) do |f|
        f.user = current_user
        f.space = folder.space
      end

      respond_with(:api, new_folder)
    end

    def update
      folder = Folder.find(params[:id])
      authorize! :manage, folder

      service = FolderService.new(:model => folder)
      service.update(params[:folder])

      respond_with(:api, service.model)
    end

    def destroy
      folder = Folder.find(params[:id])
      authorize! :manage, folder

      service = FolderService.new(:model => folder)
      service.destroy

      respond_with(:api, service.model)
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
