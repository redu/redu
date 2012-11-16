class UserSpaceAssociation < ActiveRecord::Base
  # Em alguns casos o enrollment é chamado utilizando o gem activerecord-import
  # por questões de otimização. Este gem desabilita qualquer tipo de callback
  # cuidado ao adicionar callbacks a esta entidade.
  belongs_to :user
  belongs_to :space

  enumerate :role

  scope :users_by_name,
    lambda { |name| includes(:user).
      where("users.first_name LIKE :keyword OR
             users.last_name LIKE :keyword OR
             users.login LIKE :keyword", {:keyword => "%#{name}%"})
  }

  validates_uniqueness_of :user_id, :scope => :space_id

  def self.create_policy_for(usas)
    usas.each do |usa|
      UserSpaceAssociationPolicyObserver.instance.after_create(usa)
    end
  end
end
