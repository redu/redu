class Resource < ActiveRecord::Base
  
  
  has_and_belongs_to_many :courses
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :subjects
  #has_and_belongs_to_many :workspaces
  
  has_attached_file :attachment # prepare_options_for_attachment_fu(AppConfig.resource['attachment_fu_options']) 
  validates_attachment_presence :attachment
  
  validates_presence_of :name
  
end
