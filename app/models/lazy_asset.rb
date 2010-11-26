class LazyAsset < ActiveRecord::Base
  belongs_to :subject

  validates_uniqueness_of :assetable_id, :scope => [:assetable_type, :subject_id]
  validates_presence_of :name, :lazy_type, :assetable_id, :assetable_type
  
  validation_group :lazy, :fields => [:name, :lazy_type]
  validation_group :existent, :fields => [:assetable_id, :assetable_type]

  def enable_correct_validation_group!
    
    if self.existent?
      self.enable_validation_group(:existent)
    else
      self.enable_validation_group(:lazy)
    end
  end
end
