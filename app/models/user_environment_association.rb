class UserEnvironmentAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :environment
  has_enumerated :role

  # Filtra por papéis (lista)
  named_scope :with_roles, lambda { |roles|
      unless roles.empty?
        { :conditions => { :role_id => roles.flatten } }
      end
    }
  # Filta por palavra-chave (procura em User)
  named_scope :with_keyword, lambda { |keyword|
      if not keyword.empty? and keyword.size > 4
        { :conditions => [ "users.first_name LIKE :keyword " + \
            "OR users.last_name LIKE :keyword " + \
            "OR users.login LIKE :keyword", {:keyword => "%#{keyword}%"}],
          :include => [{ :user => {:user_course_association => :course} }]}
      end
    }
  validates_uniqueness_of :user_id, :scope => :environment_id
end
