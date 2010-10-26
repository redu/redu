class SpaceAsset < ActiveRecord::Base
  
  validates_uniqueness_of :asset_id, :scope => :space_id

  belongs_to :asset, :polymorphic => true
  belongs_to :space

  protected
  def increment_courses_count
    self.space.courses_count += 1
    self.space.save
  end

  def decrement_courses_count
    self.space.courses_count -= 1
    self.space.save
  end

end
