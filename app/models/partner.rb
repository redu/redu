class Partner < ActiveRecord::Base
  has_many :partner_environment_associations, :order => "partner_environment_associations.created_at DESC"
  has_many :environments, :through => :partner_environment_associations,
    :order => "partner_environment_associations.created_at DESC"
  has_many :users, :through => :partner_user_associations
  has_many :partner_user_associations

  validates_presence_of :name, :email, :cnpj

  # Adiciona colaborador ao parcendo, dando acesso de administrador a todos os
  # ambientes associados.
  def add_collaborator(user, role=Role[:environment_admin])
    self.users << user
    join_hierarchy(user, role)
  end

  # Adiciona environment existente ao conjunto de environments do parceiro.
  # Também transforma os administadores do parceiro em admins do ambiente
  def add_environment(environment, cnpj)
    ass = self.partner_environment_associations.create(:cnpj => cnpj,
                                                       :environment => environment)
    self.users.each do |user|
      join_hierarchy(user)
    end
  end

  def join_hierarchy(user, role=Role[:environment_admin])
    self.environments.all(:include => :courses).each do |e|
      UserEnvironmentAssociation.create(:environment => e,
                                        :user => user,
                                        :role => role)

      e.courses.each do |c|
        ass = UserCourseAssociation.create(:user => user,
                                     :course => c,
                                     :role => role)
        # Callback cria as outras associações da hierarquia (Environment,
        # Space, Subject).
        ass.approve!
      end
    end
  end

  # Returns all environments' invoices
  def invoices
    plans_ids = self.environments.collect { |e| e.plans.collect(&:id) }
    Invoice.where(:plan_id => plans_ids.flatten)
  end

  def formatted_cnpj
    self.cnpj =~ /(\d{2})\.?(\d{3})\.?(\d{3})\/?(\d{4})-?(\d{2})/
    "#{$1}.#{$2}.#{$3}/#{$4}-#{$5}"
  end
end
