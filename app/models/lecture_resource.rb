class LectureResource < ActiveRecord::Base

  # ASSOCIATIONS
  has_attached_file :attachment, Redu::Application.config.paperclip_myfile
  belongs_to :attachable, :polymorphic => true

  # VALIDATIONS
  validates_presence_of :attachment
  validates_attachment_presence :attachment
  validates_attachment_size :attachment,
    :less_than => 50.megabytes

end
