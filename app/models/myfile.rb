require 'zip/zipfilesystem'

# Files in the database are represented by Myfile.
# It's called Myfile, because File is a reserved word.
# Files are in (belong to) a folder and are uploaded by (belong to) a User.
class Myfile < ActiveRecord::Base
  CONTENT_TYPES = [
    'application/pdf',
    'application/msword',
    'application/mspowerpoint',
    'application/x-pptx',
    'application/vnd.ms-powerpoint',
    'application/excel',
    'application/vnd.ms-excel',
    'application/postscript',
    'text/plain',
    'text/rtf',
    'application/rtf',
    'application/vnd.oasis.opendocument.text',
    'application/vnd.oasis.opendocument.presentation',
    'application/vnd.oasis.opendocument.spreadsheet',
    'application/vnd.sun.xml.writer',
    'application/vnd.sun.xml.impress',
    'application/vnd.sun.xml.calc',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
    'application/vnd.openxmlformats-officedocument.presentationml.template',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
    'image/jpeg',
    'image/png',
    'image/gif'
  ]

  before_destroy :delete_file_on_disk
  before_create :overwrite

  has_attached_file :attachment, Redu::Application.config.paperclip_myfiles

  belongs_to :folder
  belongs_to :user
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'

  validates_attachment_presence :attachment
  validates_attachment_size :attachment,
    :less_than => 10.megabytes
  validates_uniqueness_of :attachment_file_name, :scope => 'folder_id'
  validates_attachment_content_type :attachment, :content_type => CONTENT_TYPES

  # When removing a myfile record from the database,
  # the actual file on disk has to be removed too.
  # That is exactly what this method does.
  def delete_file_on_disk
    # File.delete self.path
  end

  def overwrite # TODO ao fazer o upload verificar e perguntar se sobrescreve ou nao
    existing = Myfile.find_by_attachment_file_name(self.attachment_file_name)
    if existing
      existing.destroy
    end
  end

  # Verifica se o curso tem espaço suficiente para o arquivo
  def can_upload_file?
    space = self.folder.space
    return false if space.course.plan.state != "active"

    plan = space.course.plan
    quota = space.course.quota

    quota.files <= plan.file_storage_limit
  end
end
