class Partner < ActiveRecord::Base
  has_many :partner_environment_associations,
    :order => "partner_environment_associations.created_at DESC",
    :dependent => :destroy
  has_many :environments, :through => :partner_environment_associations,
    :order => "partner_environment_associations.created_at DESC",
    :dependent => :destroy
  has_many :users, :through => :partner_user_associations
  has_many :partner_user_associations, :dependent => :destroy

  validates_presence_of :name, :email, :cnpj, :address

  # Adiciona colaborador ao parcendo, dando acesso de administrador a todos os
  # ambientes associados.
  def add_collaborator(user, role=Role[:environment_admin])
    self.users << user
    join_hierarchy(user, role)
  end

  # Adiciona environment existente ao conjunto de environments do parceiro.
  # Também transforma os administadores do parceiro em admins do ambiente
  def add_environment(environment, cnpj, address, company_name)
    ass = self.partner_environment_associations.
      create(:cnpj => cnpj, :address => address, :company_name => company_name,
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
  # Feito desta forma, pois o environment pode ter sido destruído
  def invoices
    plans_ids = self.partner_environment_associations.collect do |assoc|
      Plan.where(:billable_id => assoc.environment_id,
                 :billable_type => "Environment").collect(&:id)
    end
    Invoice.where(:plan_id => plans_ids.flatten)
  end

  def formatted_cnpj
    self.cnpj =~ /(\d{2})\.?(\d{3})\.?(\d{3})\/?(\d{4})-?(\d{2})/
    "#{$1}.#{$2}.#{$3}/#{$4}-#{$5}"
  end
end
