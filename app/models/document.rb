class Document < ActiveRecord::Base
  has_ipaper_and_uses 'Paperclip'
  has_attached_file :attachment, DOCUMENT_STORAGE_OPTIONS
  #validates_attachment_content_type :attachment, :content_type => ScribdFu::ContentTypes

  validate :content_type

  has_one :lecture, :as => :lectureable

  # Deriva o content type olhando diretamente para o arquivo. Workaround para
  # problemas decorrentes da integração uploadify/rails
  # http://github.com/alainbloch/uploadify_rails
  def define_content_type
    return if self.attachment_file_name.empty?
    self.attachment_content_type = MIME::Types.type_for(self.attachment_file_name).to_s
  end

  def content_type
    self.define_content_type
    unless self.accepted_content_type?
      self.errors.add(:attachment, "Formato inválido")
    end
  end

  # Verifica se o curso tem espaço suficiente para o arquivo
  def can_upload_document?(lecture)
    return false if lecture.subject.space.course.plan.state != "active"
    plan = lecture.subject.space.course.plan
    quota = lecture.subject.space.course.quota

    if quota.files > plan.file_storage_limit
      return false
    else
      return true
    end
  end

end
