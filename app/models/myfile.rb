# -*- encoding : utf-8 -*-
require 'zip/zipfilesystem'

# Files in the database are represented by Myfile.
# It's called Myfile, because File is a reserved word.
# Files are in (belong to) a folder and are uploaded by (belong to) a User.
class Myfile < ActiveRecord::Base
  CONTENT_TYPES =  Redu::Application.config.mimetypes['image'] + \
    Redu::Application.config.mimetypes['documents'] + \
    Redu::Application.config.mimetypes['audio']

  has_attached_file :attachment, Redu::Application.config.paperclip_myfiles

  belongs_to :folder
  belongs_to :user

  scope :recent, lambda { where("attachment_updated_at > ?", 1.week.ago) }

  validates_attachment_presence :attachment
  validates_attachment_size :attachment,
    :less_than => 100.megabytes
  validates_uniqueness_of :attachment_file_name, :scope => 'folder_id'
  validates_attachment_content_type :attachment, :content_type => CONTENT_TYPES
end
