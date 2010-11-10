class Course < ActiveRecord::Base
  belongs_to :environment
  has_many :spaces, :dependent => :destroy
  has_many :user_course_association, :dependent => :destroy
  belongs_to :owner, :class_name => "User", :foreign_key => "owner"
  has_many :users, :through => :user_course_association
  has_many :approved_users, :through => :user_course_association,
    :source => :user, :conditions => [ "user_course_associations.state = ?", 'approved' ]
  has_many :invitations, :as => :inviteable, :dependent => :destroy

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
end
