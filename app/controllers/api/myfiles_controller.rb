# -*- encoding : utf-8 -*-
module Api
  class MyfilesController < Api::ApiController
    include Api::RepresenterInflector

    def index
      folder = Folder.find(params[:folder_id])
      authorize! :read, folder
      files = folder.myfiles

      respond_with files
    end

    def show
      file = Myfile.find(params[:id])
      authorize! :read, file

      respond_with file
    end

    def create
      folder = Folder.find(params[:folder_id])
      authorize! :manage, folder

      options = { attachment: params[:file][:content] }
      service = MyfileService.new(options)
      file = service.create do |myfile|
        myfile.folder = folder
        myfile.user = current_user
      end

      respond_with(:api, file)
    end

    def destroy
      file = Myfile.find(params[:id])
      service = MyfileService.new(model: file)

      authorize! :manage, file

      service.destroy

      respond_with file
    end
  end
end
