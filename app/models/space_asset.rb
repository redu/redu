class SpaceAsset < ActiveRecord::Base
  
  validates_uniqueness_of :asset_id, :scope => :school_id

  belongs_to :asset, :polymorphic => true
  belongs_to :school

  protected
  def increment_courses_count
    self.school.courses_count += 1
    self.school.save
  end

  def decrement_courses_count
    self.school.courses_count -= 1
    self.school.save
  end

end
