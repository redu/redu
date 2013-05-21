# -*- encoding : utf-8 -*-
module Api
  module FolderRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :name
    property :date_modified, :if => lambda { self.date_modified }

    link :self do
      api_folder_url(self)
    end

    link :folder do
      api_folder_url(self.parent) if self.parent
    end

    link :files do
      api_folder_myfiles_url(self)
    end

    link :folders do
      api_folder_folders_url(self)
    end

    link :space do
      api_space_url(self.space)
    end

    link :user do
      api_user_url(self.user) if self.user
    end
  end
end
