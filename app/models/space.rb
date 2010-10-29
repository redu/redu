class Space < ActiveRecord::Base
  # Representa um espaço de ensino. O objetivo principal do Space é agrupar
  # objetos de ensino (Lecture e Subject) e promover a interação de muitos
  # para muitos entre os usuários (Status).
  #
  # Além disso, o Space fornece mecanismos para compartilhamento de arquivos
  # (MyFile), veículação de comunicados (Bulletin) e eventos (Event).

  # CALLBACKS
  before_create :create_root_folder

  # USERS
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  has_many :user_space_associations, :dependent => :destroy
  has_many :users, :through => :user_space_associations,
    :conditions => ["user_space_associations.status LIKE 'approved'"]
  # Os membros podem possuir permissões especiais
  has_many :admins, :through => :user_space_associations, :source => :user,
    :conditions => [ "user_space_associations.role_id = ?", 4 ]
  has_many :coordinators, :through => :user_space_associations, :source => :user,
    :conditions => [ "user_space_associations.role_id = ?", 5 ]
  has_many :teachers, :through => :user_space_associations, :source => :user,
    :conditions => [ "user_space_associations.role_id = ?", 6 ]
  has_many :students, :through => :user_space_associations, :source => :user,
    :conditions => [ "user_space_associations.role_id = ?", 7 ]
  has_many :pending_requests, :class_name => "UserSpaceAssociation",
    :conditions => ["user_space_associations.status LIKE 'pending'"]

  # CATEGORIES
  has_and_belongs_to_many :categories, :class_name => "ReduCategory"
  has_and_belongs_to_many :audiences

  has_many :folders
  has_many :acquisitions, :as => :acquired_by
  has_many :space_assets, :class_name => 'SpaceAsset',
    :dependent => :destroy
  has_many :lectures, :through => :space_assets,
    :source => :asset, :source_type => "Lecture", :conditions =>  "published = 1"
  has_many :exams, :through => :space_assets,
    :source => :asset, :source_type => "Exam", :conditions =>  "published = 1"
  has_many :bulletins, :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :statuses, :as => :statusable
  has_many :subjects

  named_scope :inner_categories, lambda { {:joins => :categories} } # Faz inner join com redu_categories_space

  # METODOS DO WIZARD
  attr_writer :current_step

  # PLUGINS
  acts_as_taggable
  acts_as_voteable
  has_attached_file :avatar, {
    :styles => { :medium => "200x200>", :thumb => "100x100>", :nano => "24x24>" },
    :path => "schools/:attachment/:id/:style/:basename.:extension",
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  # VALIDATIONS
  validates_presence_of :name, :path,
    :message => "Não pode ser deixado em branco"
  validates_format_of :path, :with => /^[\sA-Za-z0-9_-]+$/,
    :message => "Endereço inválido."
  validates_uniqueness_of   :path, :case_sensitive => false,
    :message => "Endereço inválido."
  validates_exclusion_of    :path, :in => AppConfig.reserved_logins,
    :message => "Endereço inválido"
  validates_presence_of :categories

  # Sobreescrevendo ActiveRecord.find para adicionar capacidade de buscar por path do Space
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      Space.find_by_path(args)
    else
      super
    end
  end

  # Utilizado nas rotas search friendly
  def to_param
    self.path
  end

  def permalink
    AppConfig.community_url + '/' + self.path
  end

  def avatar_photo_url(size = nil)
    if self.avatar_file_name
      self.avatar.url(size)
    else
      case size
      when :thumb
        AppConfig.photo['missing_thumb_space']
      else
        AppConfig.photo['missing_medium_space']
      end
    end
  end

  # Status relativos ao Space
  def recent_activity(offset = 0, limit = 20)
    self.statuses.all(:order => 'created_at DESC', :offset=> offset, :limit=> limit)
  end

  # Status relativos ao Space e a Exam
  def recent_space_exams_activity
    sql = "SELECT l.id, l.logeable_type, l.action, l.user_id, l.logeable_name, " + \
      "l.logeable_id, l.created_at, l.updated_at, l.space_id " + \
      "FROM logs l, space_assets s " + \
      "WHERE l.space_id = '#{self.id}' AND l.logeable_type = '#{Exam}' " + \
      "ORDER BY l.created_at DESC LIMIT 3 "

    @recent_exams_activity = Log.find_by_sql(sql)
  end

  # Status relativos ao Space e a Lecture
  def recent_space_lectures_activity
    sql = "SELECT l.id, l.logeable_type, l.action, l.user_id, l.logeable_name, " + \
      "l.logeable_id, l.created_at, l.updated_at, l.space_id " + \
      "FROM logs l, space_assets s " + \
      "WHERE l.space_id = '#{self.id}' AND l.logeable_type = '#{Lecture}' " + \
      "ORDER BY l.created_at DESC LIMIT 3 "

    @recent_lectures_activity = Log.find_by_sql(sql)
  end

  # Preview das Lectures mais importantes
  def spotlight_lectures
    sql =  "SELECT c.name FROM lectures c, space_assets s " + \
      "WHERE s.space_id = '#{self.id}' " + \
      "AND s.asset_type = '#{Lecture}' " + \
      "AND c.id = s.asset_id " + \
      "ORDER BY c.view_count DESC LIMIT 6 "

    Lecture.find_by_sql(sql)
  end

  def create_root_folder
    @folder = Folder.create(:name => "root")
    self.folders << @folder
  end

  def root_folder
    Folder.find(:first, :conditions => ["space_id = ? AND parent_id IS NULL", self.id])
  end

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[general settings publication]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

  def featured_lectures(qty=4)
    #TODO melhorar esta lógica
    self.lectures.find(:all, :order => "view_count DESC", :limit => "#{qty}")
  end

end
