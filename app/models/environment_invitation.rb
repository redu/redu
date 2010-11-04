class EnvironmentInvitation < ActiveRecord::Base
  # Utilizado no Environment ao convidar colaboradores no fim do processo de
  # criação. O callback User.<nome do callback> verifica se existe
  # algum EnvironmentInvitation pendente com o e-mail cadastro e adiciona o
  # usuário ao environment.

  belongs_to :environment
  belongs_to :user
  has_enumerated :role

  validates_presence_of :email, :role
  validates_format_of :email,
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create,
    :message => "E-mail inválido"
  validates_uniqueness_of :email, :case_sensitive => :false, :scope => :email,
    :message => "O e-mail informado já foi convidado uma vez"

  acts_as_state_machine :initial => :pending, :column => :state

  state :pending
  state :invited, :enter => :send_invitation
  state :added, :enter => :add_to_environment
  state :failed

  event :invite do
    transitions :from => :pending, :to => :invited
    transitions :from => :invited, :to => :invited
  end

  event :add do
    transitions :from => :invited, :to => :added
  end

  event :fail do
    transitions :from => :invited, :to => :failed
    transitions :from => :added, :to => :failed
  end

  protected

  # Envia e-mail para o colaborador convidado
  def send_invitation
    UserNotifier.deliver_environment_invitation(self.user,
                                                self.email,
                                                self.role,
                                                self.environment,
                                                self.message)
  end

  # Adiciona colaborador ao environment
  def add_to_environment

  end
end
