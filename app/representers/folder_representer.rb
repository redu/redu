module FolderRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name
  property :date_modified, :if => lambda { self.date_modified }

  link :self do
    api_folder_path(self)
  end

  link :folder do
    api_folder_path(self.parent) if self.parent
  end

  link :files do
    api_folder_files_path(self)
  end

  link :folders do
    api_folder_folders_path(self)
  end

  link :space do
    api_space_path(self.space)
  end

  link :user do
    api_user_path(self.user) if self.user
  end
end
