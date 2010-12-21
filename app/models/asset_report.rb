class AssetReport < ActiveRecord::Base
  belongs_to :asset
  belongs_to :student_profile
  belongs_to :subject
end
