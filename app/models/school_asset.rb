class SchoolAsset < ActiveRecord::Base
  
  belongs_to :asset, :polymorphic => true
  
end
