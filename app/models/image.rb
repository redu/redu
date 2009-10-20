class Image < ActiveRecord::Base
  has_attachment prepare_options_for_attachment_fu(AppConfig.image['attachment_fu_options'])
  validates_as_attachment
  
  has_one :question #, :class_name => "Question"#, :foreign_key => "image_id"
  
end
