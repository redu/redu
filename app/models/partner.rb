class Partner < ActiveRecord::Base
  has_many :partner_environment_associations, :order => "partner_environment_associations.created_at DESC"
  has_many :environments, :through => :partner_environment_associations,
    :order => "partner_environment_associations.created_at DESC"
  has_many :users, :through => :partner_user_associations
  has_many :partner_user_associations

  validates_presence_of :name, :email

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
        c.create_hierarchy_associations(user, role)
        ass = UserCourseAssociation.create(:user => user,
                                     :course => c,
                                     :role => role)
        ass.approve!
      end
    end
  end
end
