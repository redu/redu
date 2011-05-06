class Environment < ActiveRecord::Base
  # Representa o ambiente onde o ensino a distância acontece. Pode ser visto
  # como um instituição o provedor de ensino dentro do sistema.

  after_create :create_environment_association
  after_create :create_course_association, :unless => "self.courses.empty?"

  has_many :courses, :dependent => :destroy
  has_many :user_environment_associations, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_environment_associations
  # environment_admins
  has_many :administrators, :through => :user_environment_associations,
    :source => :user,
    :conditions => [ "user_environment_associations.role = ?", 3 ]
  # teachers
  has_many :teachers, :through => :user_environment_associations,
    :source => :user,
    :conditions => [ "user_environment_associations.role = ?", 5 ]
  # tutors
  has_many :tutors, :through => :user_environment_associations,
    :source => :user,
    :conditions => [ "user_environment_associations.role = ?", 6 ]
  has_many :bulletins, :as => :bulletinable, :dependent => :destroy

  attr_protected :owner, :published

  acts_as_taggable
  has_attached_file :avatar, Redu::Application.config.paperclip

  validates_presence_of :name, :path, :initials
  validates_uniqueness_of :name, :path,
    :message => "Precisa ser único"
  validates_length_of :name, :maximum => 40
  validates_length_of :description, :maximum => 400, :allow_blank => true
  validate :length_of_tags
  validates_length_of :initials, :maximum => 10, :allow_blank => true
  validates_format_of :path, :with => /^[-_.A-Za-z0-9]*$/

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
    return self.id.to_s if self.path.empty?
    self.path
  end

  def permalink
    "#{Redu::Application.config.url}/#{self.path}"
  end

  # Muda o papel do usuário levando em conta a hierarquia
  def change_role(user, role)
    membership = self.user_environment_associations.where(:user_id => user.id).
                   first
    membership.update_attributes({:role => role})

    user.user_course_associations.where(:course_id => self.courses).
      each do |membership|
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

  # Retorna as iniciais ou, se não houver, o nome
  def initials_or_name
    (self.initials.nil? or self.initials.empty?) ? self.name : self.initials
  end

  protected

  def create_environment_association
    UserEnvironmentAssociation.create(:environment => self,
                                      :user => self.owner,
                                      :role => Role[:environment_admin])
  end

  def create_course_association
    course_assoc = UserCourseAssociation.create(
      :course => self.courses.first,
      :user => self.owner,
      :role => Role[:environment_admin])
      course_assoc.approve!
  end

  def length_of_tags
    tags_str = ""
    self.tags.each {|t|  tags_str += " " + t.name }
    self.errors.add(:tags, :too_long.l) if tags_str.length > 111
  end
end
