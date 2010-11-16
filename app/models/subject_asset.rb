class SubjectAsset < ActiveRecord::Base
  
  belongs_to :asset, :polymorphic => true
  belongs_to :subject

  validates_uniqueness_of :asset_id, :scope => :subject_id

  protected
  def increment_lectures_count
    self.space.lectures_count += 1
    self.space.save
  end

  def decrement_lectures_count
    self.space.lectures_count -= 1
    self.space.save
  end

end
