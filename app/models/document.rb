class Document < ActiveRecord::Base
  has_ipaper_and_uses 'Paperclip'
  has_attached_file :attachment, DOCUMENT_STORAGE_OPTIONS

  validate :accepted_content_type

  # Deriva o content type olhando diretamente para o arquivo. Workaround para
  # problemas decorrentes da integração uploadify/rails
  # http://github.com/alainbloch/uploadify_rails
  def define_content_type
    return if self.attachment_file_name.empty?
    self.attachment_content_type = MIME::Types.type_for(self.attachment_file_name).to_s
  end

  def accepted_content_type
    self.define_content_type
    unless scribdable?
      self.errors.add(:original, "Formato inválido")
      return false
    else
      return true
    end
  end

end
