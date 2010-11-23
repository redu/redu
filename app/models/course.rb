class Course < ActiveRecord::Base
  belongs_to :environment
  has_many :spaces, :dependent => :destroy
  has_many :user_course_associations, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_course_association
  has_many :approved_users, :through => :user_course_associations,
    :source => :user, :conditions => [ "user_course_associations.state = ?", 'approved' ]
  has_many :invitations, :as => :inviteable, :dependent => :destroy

  named_scope :published, :conditions => {:published => 1}

  acts_as_taggable

  validates_presence_of :name, :message => "Não pode ficar em branco."

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


end
