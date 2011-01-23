class Course < ActiveRecord::Base

  after_create :create_user_course_association

  belongs_to :environment
  has_many :spaces, :dependent => :destroy
  has_many :user_course_associations, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_course_associations
  has_many :approved_users, :through => :user_course_associations,
    :source => :user, :conditions => [ "user_course_associations.state = ?", 'approved' ]
  has_many :invitations, :as => :inviteable, :dependent => :destroy
  has_and_belongs_to_many :audiences
  has_one :quota, :dependent => :destroy, :as => :billable

  named_scope :of_environment, lambda { |environmnent_id|
   { :conditions => {:environment_id => environmnent_id} }
  }

  attr_protected :owner, :published, :environment

  acts_as_taggable

  validates_presence_of :name, :path
  validates_uniqueness_of :name, :path, :scope => :environment_id

  # Sobreescrevendo ActiveRecord.find para adicionar capacidade de buscar por path do Space
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_path(*args)
    else
      super
    end
  end

  def to_param
    self.path
  end

  def permalink
    "#{AppConfig.community_url}/#{self.environment.path}/cursos/#{self.path}"
  end

  def can_be_published?
    self.spaces.published.size > 0
  end

  # Muda papeis deste ponto para baixo na hieararquia
  def change_role(user, role)
    membership = user.user_course_associations.find(:first,
                    :conditions => {:course_id => self.id})
    membership.update_attributes({:role_id => role.id})

    user.user_space_associations.find(:all,
                     :conditions => {:space_id => self.spaces},
                     :include => [:space]).each do |membership|
      membership.space.change_role(user, role)
    end
  end

  # Verifica se o path escolhido para o Course já é utilizado por outro
  # no mesmo Environment. Caso seja, um novo path é gerado.
  def verify_path!(environment_id)
    path  = self.path
    if Course.all(:conditions => ["environment_id = ? AND path = ?",
                  environment_id, self.path])
      self.path += '-' + SecureRandom.hex(1)

      # Mais uma tentativa para utilizar um path não existente.
      return if Course.all(:conditions => ["environment_id = ? AND path = ?",
                               environment_id, self.path]).empty?
      self.path = path + '-' + SecureRandom.hex(1)
    end

  end
  def create_user_course_association
    user_course =
      UserCourseAssociation.create(:user => self.owner,
                                   :course => self,
                                   :role => Role[:environment_admin])
      user_course.approve!
  end
end
