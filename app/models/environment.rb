class Environment < ActiveRecord::Base
  # Representa o ambiente onde o ensino a distância acontece. Pode ser visto
  # como um instituição o provedor de ensino dentro do sistema.

  has_many :courses, :dependent => :destroy
  has_many :user_environment_associations, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_environment_associations
  has_many :bulletins, :as => :bulletinable, :dependent => :destroy

  attr_protected :owner, :published

  after_create :create_environment_association
  after_create :create_course_association

  acts_as_taggable
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS.deep_merge({
    :styles => { :environment => "145x125>" }
  })

  validates_presence_of :name, :path
  validates_uniqueness_of :name, :path,
    :message => "Precisa ser único"
  validates_length_of :name, :maximum => 40
  validates_length_of :initials, :maximum => 10, :allow_blank => true

  accepts_nested_attributes_for :courses

  # Sobreescrevendo ActiveRecord.find para adicionar capacidade de buscar por path do Space
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_path(args)
    else
      super
    end
  end

  def to_param
    self.path
  end

  def permalink
    "#{AppConfig.community_url}/#{self.path}"
  end

  # Muda o papel do usuário levando em conta a hierarquia
  def change_role(user, role)
    membership = self.user_environment_associations.find(:first,
                    :conditions => {:user_id => user.id})
    membership.update_attributes({:role_id => role.id})

      user.user_course_associations.all(
        :conditions => {:course_id => self.courses}).each do |membership|
        membership.course.change_role(user, role)
      end
  end

  # Verifica se o path escolhido para o Environment já é utilizado por
  # outro, caso seja, um novo path é gerado.
  def verify_path!
    path  = self.path
    if Environment.find_by_path(self.path)
      self.path += '-' + SecureRandom.hex(1)

      # Mais uma tentativa para utilizar um path não existente.
      return unless Environment.find_by_path(self.path)
      self.path = path + '-' + SecureRandom.hex(1)
    end
  end
protected

  def create_environment_association
    UserEnvironmentAssociation.create(:environment => self,
                                      :user => self.owner,
                                      :role_id => Role[:environment_admin].id)
  end

  def create_course_association
    UserCourseAssociation.create(
      :course => self.courses.first,
      :user => self.owner,
      :role_id => Role[:environment_admin].id, :state => 'approved')
  end
end
