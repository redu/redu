module MyfileRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  include ActionView::Helpers::NumberHelper

  property :id
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
    number_to_human_size(self.attachment_file_size)
  end

  def byte
    self.attachment_file_size
  end
end
