class UserSpaceAssociation < ActiveRecord::Base

  after_create :increment_members_count
  before_destroy :decrement_members_count

  belongs_to :user
  belongs_to :space

  enumerate :role

  # FIXME Remover ao retirar status do modelo
  scope :approved, where(:status => 'approved')
  scope :users_by_name,
    lambda { |name| includes(:user).
      where("users.first_name LIKE :keyword OR
             users.last_name LIKE :keyword OR
             users.login LIKE :keyword", {:keyword => "%#{name}%"})
  }

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
