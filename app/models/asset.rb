class Asset < ActiveRecord::Base
  belongs_to :subject
  belongs_to :assetable, :polymorphic => true
  belongs_to :lazy_asset

  validates_uniqueness_of :assetable_id, :scope => :subject_id
end
