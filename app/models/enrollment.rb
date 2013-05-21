# -*- encoding : utf-8 -*-
class Enrollment < ActiveRecord::Base
  include EnrollmentService::EnrollmentAdditions::ModelAdditions

  # Entidade intermediária entre User e Subject. É criada quando o usuário se
  # matricula num determinado Subject.
  # Contém informações sobre aulas realizadas, porcentagem do Subject cursado
  # e informações sobre desempenho no Subject.

  belongs_to :user
  belongs_to :subject
  has_many :asset_reports, :dependent => :destroy
  has_many :lectures, :through => :asset_reports

  classy_enum_attr :role, :default => 'member'

  validates_uniqueness_of :user_id, :scope => :subject_id

  # FIXME Testar
  # Filtra por papéis (lista)
  scope :with_roles, lambda { |roles|
    unless roles.empty?
      where(:role => roles.flatten)
    end
  }

  # FIXME Testar
  # Filtra por palavra-chave (procura em User)
  scope :with_keyword, lambda { |keyword|
    if not keyword.empty? and keyword.size > 2
      where("users.first_name LIKE :keyword " + \
        "OR users.last_name LIKE :keyword " + \
        "OR users.login LIKE :keyword", {:keyword => "%#{keyword.to_s}%"})
    end
  }
end
