class Space < ActiveRecord::Base
  # Representa uma disciplina de ensino. O objetivo principal do Space é agrupar
  # objetos de ensino (Lecture e Subject) e promover a interação de muitos
  # para muitos entre os usuários (Status e Forum).
  #
  # Além disso, o Space fornece mecanismos para compartilhamento de arquivos
  # (MyFile), veículação de comunicados (Bulletin e Forum) e eventos (Event).

  # CALLBACKS
  before_create :create_root_folder

  belongs_to :course

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
    :conditions => [ "user_space_associations.role_id = ?", 3 ]
  has_many :pending_requests, :class_name => "UserSpaceAssociation",
    :conditions => ["user_space_associations.status LIKE 'pending'"]
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'

  has_many :folders, :dependent => :destroy
  has_many :acquisitions, :as => :acquired_by
  has_many :bulletins, :as => :bulletinable, :dependent => :destroy
  has_many :events, :as => :eventable, :dependent => :destroy
  has_many :statuses, :as => :statusable, :dependent => :destroy
  has_many :subjects, :dependent => :destroy
  has_many :topics # Apenas para facilitar a busca.
  has_many :sb_posts # Apenas para facilitar a busca.
  has_one :forum, :dependent => :destroy

  named_scope :published, :conditions => {:published => 1}
  named_scope :of_course, lambda { |course_id|
     { :conditions => {:course_id => course_id} }
  }
  # METODOS DO WIZARD
  attr_writer :current_step

  # PLUGINS
  acts_as_taggable
  acts_as_voteable
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS

  # VALIDATIONS
  validates_presence_of :name, :description, :submission_type,
    :message => "Não pode ser deixado em branco"

  validation_group :general, :fields => [:name, :description]
  validation_group :settings, :fields => [:submission_type]

  # Utilizado nas rotas search friendly
  def to_param
    "#{ self.id }-#{ name.parameterize }"
  end

  def permalink
    APP_URL + '/espacos/' + self.id.to_s + '-' + self.name.parameterize
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
  def recent_activity(page = 1)
    self.statuses.paginate(:all, :page => page, :order => 'created_at DESC',
                           :per_page => AppConfig.items_per_page)
  end

  # Logs relativos ao Space (usado no Course#show).
  # Retorna hash do tipo :topoic => [status1, status2, status3], :myfile => ...
  def recent_log(offset = 0, limit = 3)
    logs = {}
    logs[:myfile] = self.statuses.find(:all,
                                       :order => 'created_at DESC',
                                       :limit => limit,
                                       :offset => offset,
                                       :conditions => { :log => 1,
                                         :logeable_type => 'Myfile' })
    logs[:topic] = self.statuses.find(:all,
                                      :order => 'created_at DESC',
                                      :limit => limit,
                                      :offset => offset,
                                      :conditions => { :log => true,
                                        :logeable_type => %w(Topic SbPost) })
    logs[:subject] = self.statuses.find(:all,
                                        :order => 'created_at DESC',
                                        :limit => limit,
                                        :offset => offset,
                                        :conditions => { :log => true,
                                          :logeable_type => 'Subject' })
    logs[:event] = self.statuses.find(:all,
                                      :order => 'created_at DESC',
                                      :limit => limit,
                                      :offset => offset,
                                      :conditions => { :log => true,
                                        :logeable_type  => 'Event' })
    logs[:bulletin] = self.statuses.find(:all,
                                         :order => 'created_at DESC',
                                         :limit => limit,
                                         :offset => offset,
                                         :conditions => { :log => true,
                                           :logeable_type => 'Bulletin' })
    return logs
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
    %w[general settings]
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

  # Muda papeis deste ponto para baixo na hieararquia
  def change_role(user, role)
    membership = self.user_space_associations.find(:first,
                    :conditions => {:user_id => user.id})
    membership.update_attributes({:role_id => role.id})
  end

  def enable_correct_validation_group!
    self.enable_validation_group(self.current_step.to_sym)
  end

end
