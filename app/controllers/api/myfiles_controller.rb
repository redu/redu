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
  end
end
