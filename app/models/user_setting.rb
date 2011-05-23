class UserSetting < ActiveRecord::Base
  belongs_to :user
  enumerate :view_mural, :with => Privacy
end
