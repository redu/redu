class UserEnvironmentAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :environment
  classy_enum_attr :role, :default => 'member'

  # Filtra por papéis (lista)
  scope :with_roles, lambda { |roles|
      unless roles.empty?
        where(:role => roles.flatten)
      end
  }
  # Filtra por palavra-chave (procura em User)
  scope :with_keyword, lambda { |keyword|
      if not keyword.empty? and keyword.size > 4
        where("users.first_name LIKE :keyword " + \
            "OR users.last_name LIKE :keyword " + \
            "OR users.login LIKE :keyword", {:keyword => "%#{keyword.to_s}%"}).
        includes(:user => [{:user_course_associations => :course}])
      end
    }
  # Filtra por Environment
  scope :of_environment, lambda { |env_id|
    where("user_environment_associations.environment_id = ?", env_id)
  }

  validates_uniqueness_of :user_id, :scope => :environment_id
end
