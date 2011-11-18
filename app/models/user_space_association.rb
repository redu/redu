class UserSpaceAssociation < ActiveRecord::Base

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

end
