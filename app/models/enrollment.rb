class Enrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject
  belongs_to :role
  has_one :student_profile, :dependent => :destroy

  validates_uniqueness_of :user_id, :scope => :subject_id

  # Filtra por papéis (lista)
  named_scope :with_roles, lambda { |roles|
    unless roles.empty?
      { :conditions => { :role_id => roles.flatten } }
    end
  }

  # Filtra por palavra-chave (procura em User)
  named_scope :with_keyword, lambda { |keyword|
    if not keyword.empty? and keyword.size > 4
      { :conditions => [ "users.first_name LIKE :keyword " + \
        "OR users.last_name LIKE :keyword " + \
        "OR users.login LIKE :keyword", {:keyword => "%#{keyword}%"}]}
    end
  }
end
