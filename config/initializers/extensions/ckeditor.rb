# Monkeypatch necessário para utilizar a versão 3.4.2.pre do
# ckeditor gem com o Rails 3.2.
module Ckeditor
  mattr_accessor :file_manager_image_model
  @@file_manager_image_model = "Ckeditor::Picture"

  mattr_accessor :file_manager_file_model
  @@file_manager_file_model = "Ckeditor::AttachmentFile"

  # Get the image class from the image reference object.
  def self.image_model
    @@file_manager_image_model.to_s.classify.constantize
  end

  # Get the file class from the file reference object.
  def self.file_model
    @@file_manager_file_model.to_s.classify.constantize
  end
end

