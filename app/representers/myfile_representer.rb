module MyfileRepresenter
  MEGABYTE = 1024.0 * 1024.0
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :name
  property :mimetype
  property :size
  property :byte

  link :self do
    api_myfile_url(self)
  end

  link :folder do
    api_folder_url(self)
  end

  link :space do
    api_space_url(self.folder.space)
  end

  link :user do
    api_user_url(self.user)
  end

  link :raw do
    self.attachment.url
  end

  def name
    self.attachment_file_name
  end

  def mimetype
    self.attachment_content_type
  end

  def size
    self.attachment_file_size / MEGABYTE
  end

  def byte
    self.attachment_file_size
  end
end
