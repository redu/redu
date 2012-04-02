class License < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :course

  validates_presence_of :name, :email, :period_start, :role, :course, :invoice
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  # Retorna todas as licenças que estão em uso
  scope :in_use, where(:period_end => nil)
  scope :of_course, lambda { |course|
    where(:course_id => course)
  }
  # Retorna todas as licenças consideradas pagáveis
  scope :payable, where(:role => Role[:member])

  # Recupera o último license criado e modifica a role passada como parâmetro
  def self.change_role(user, course, role)
    license = License.get_open_license_with(user, course)
    if license
      license.role = role
      license.save
    end
  end

  def self.get_open_license_with(user, course)
    License.where('login LIKE ? AND course_id = ? AND period_end IS NULL',
                  user.login, course).first
  end
end
