class UserSpaceAssociation < ActiveRecord::Base

  belongs_to :user
  belongs_to :school

  belongs_to :access_key
  has_enumerated :role 

  after_create :increment_members_count
  before_destroy :decrement_members_count

  protected
  def increment_members_count
    self.school.members_count += 1
    self.school.save
  end

  def decrement_members_count
    self.school.members_count -= 1
    self.school.save
  end

end
