class SchoolAsset < ActiveRecord::Base

  belongs_to :asset, :polymorphic => true
  belongs_to :school

  validates_uniqueness_of :asset_id, :scope => :school_id

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
