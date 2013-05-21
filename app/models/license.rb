# -*- encoding : utf-8 -*-
class License < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :course

  classy_enum_attr :role

  validates_presence_of :name, :email, :period_start, :course, :invoice
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  # Retorna todas as licenças que estão em uso
  scope :in_use, where(:period_end => nil)
  scope :of_course, lambda { |course|
    where(:course_id => course)
  }
  # Scopes que precisam ser interpretados em tempo de execução
  class << self
    # Retorna todas as licenças consideradas pagáveis
    def payable
      where(:role => Role[:member])
    end
  end

  # Quantidade de dias da licença
  def total_days
    (self.period_end - self.period_start + 1).to_i
  end

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
