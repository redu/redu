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
    # self.scribdable? retorna falso se o doc. já foi enviado p/ conversão
    if self.ipaper_id.blank? || self.scribdable?
      self.errors.add(:attachment, "Formato inválido")
      return false
    else
      return true
    end
  end

end
