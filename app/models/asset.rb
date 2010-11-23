class Asset < ActiveRecord::Base
  belongs_to :subject
  belongs_to :assetable, :polymorphic => true

  validates_uniqueness_of :asset_id, :scope => :subject_id
end
