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
  has_many :teachers, :through => :user_space_associations, :source => :user,
    :conditions => [ "user_space_associations.role_id = ?", 6 ]
  has_many :students, :through => :user_space_associations, :source => :user,
    :conditions => [ "user_space_associations.role_id = ?", 3 ]
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'

  has_many :folders, :dependent => :destroy
  has_many :bulletins, :as => :bulletinable, :dependent => :destroy
  has_many :events, :as => :eventable, :dependent => :destroy
  has_many :statuses, :as => :statusable, :dependent => :destroy
  has_many :subjects, :dependent => :destroy
  has_many :topics # Apenas para facilitar a busca.
  has_many :sb_posts # Apenas para facilitar a busca.
  has_one :forum, :dependent => :destroy
  has_one :root_folder, :class_name => 'Folder', :foreign_key => 'space_id'

  named_scope :published, :conditions => {:published => 1}
  named_scope :of_course, lambda { |course_id|
     { :conditions => {:course_id => course_id} }
  }

  # PLUGINS
  acts_as_taggable
  acts_as_voteable
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS

  # VALIDATIONS
  validates_presence_of :name, :description, :submission_type

  def permalink
    APP_URL + '/espacos/' + self.id.to_s + '-' + self.name.parameterize
  end

  #FIXME Resolver através do Paperclip
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
  #FIXME Refactor: Mover para Status
  def recent_activity(page = 1)
    self.statuses.paginate(:all, :page => page, :order => 'created_at DESC',
                           :per_page => AppConfig.items_per_page)
  end

  # Logs relativos ao Space (usado no Course#show).
  # Retorna hash do tipo :topoic => [status1, status2, status3], :myfile => ...
  #FIXME Refactor: Mover para Status
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

  # Muda papeis deste ponto para baixo na hieararquia
  def change_role(user, role)
    membership = self.user_space_associations.find(:first,
                    :conditions => {:user_id => user.id})
    membership.update_attributes({:role_id => role.id})
  end

  #FIXME Remover quando a criação deixar de ser Wizard
  def enable_correct_validation_group!
    self.enable_validation_group(self.current_step.to_sym)
  end

end
