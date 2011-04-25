class UserSetting < ActiveRecord::Base
  belongs_to :user
  has_enumerated :view_mural, :class_name => 'Privacy'
end
