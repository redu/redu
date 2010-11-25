class LazyAsset < ActiveRecord::Base
  belongs_to :subject

  validates_uniqueness_of :assetable_id, :scope => :subject_id
  validates_presence_of :name
  validates_presence_of :lazy_type
end
