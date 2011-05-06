class Enrollment < ActiveRecord::Base
  # Entidade intermediária entre User e Subject. É criada quando o usuário se
  # matricula num determinado Subject.

  after_create :creates_student_profile

  belongs_to :user
  belongs_to :subject
  has_one :student_profile, :dependent => :destroy

  enumerate :role

  validates_uniqueness_of :user_id, :scope => :subject_id

  # FIXME Testar
  # Filtra por papéis (lista)
  scope :with_roles, lambda { |roles|
    unless roles.empty?
      where(:role_id => roles.flatten)
    end
  }

  # FIXME Testar
  # Filtra por palavra-chave (procura em User)
  scope :with_keyword, lambda { |keyword|
    if not keyword.empty? and keyword.size > 4
      where("users.first_name LIKE :keyword " + \
        "OR users.last_name LIKE :keyword " + \
        "OR users.login LIKE :keyword", {:keyword => "%#{keyword}%"})
    end
  }

  protected
  def creates_student_profile
    self.create_student_profile(:user => self.user, :subject => self.subject)
  end
end
