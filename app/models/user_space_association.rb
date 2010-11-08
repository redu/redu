class UserSpaceAssociation < ActiveRecord::Base

  after_create :increment_members_count
  before_destroy :decrement_members_count

  belongs_to :user
  belongs_to :space

  belongs_to :access_key
  has_enumerated :role 

  validates_uniqueness_of :user_id, :scope => :space_id

  protected
  def increment_members_count
    self.space.members_count += 1
    self.space.save
  end

  def decrement_members_count
    self.space.members_count -= 1
    self.space.save
  end

end
