class Space < ActiveRecord::Base
  # Representa uma disciplina de ensino. O objetivo principal do Space é agrupar
  # objetos de ensino (Lecture e Subject) e promover a interação de muitos
  # para muitos entre os usuários (Status e Forum).
  #
  # Além disso, o Space fornece mecanismos para compartilhamento de arquivos
  # (MyFile), veículação de comunicados (Bulletin e Forum) e eventos (Event).

  # CALLBACKS
  before_create :create_root_folder
  after_create :create_forum
  after_create :create_space_association_for_users_course

  # ASSOCIATIONS
  belongs_to :course

  # USERS
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner"
  has_many :user_space_associations, :dependent => :destroy
  #FIXME retirar o conditions, o status de user_space_associations será
  # retirado
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
  has_many :subjects, :dependent => :destroy,
    :conditions => { :finalized => true }
  has_many :topics # Apenas para facilitar a busca.
  has_many :sb_posts # Apenas para facilitar a busca.
  has_one :forum, :dependent => :destroy
  has_one :root_folder, :class_name => 'Folder', :foreign_key => 'space_id'

  named_scope :of_course, lambda { |course_id|
     { :conditions => {:course_id => course_id} }
  }

  # ACCESSORS
  attr_protected :owner, :removed, :lectures_count, :members_count,
                 :course_id, :published

  # PLUGINS
  acts_as_taggable
  acts_as_voteable
  has_attached_file :avatar, PAPERCLIP_STORAGE_OPTIONS

  # VALIDATIONS
  validates_presence_of :name, :description, :submission_type
  validates_length_of :name, :maximum => 40

  def permalink
    APP_URL + '/espacos/' + self.id.to_s + '-' + self.name.parameterize
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

  # Muda papeis neste ponto da hieararquia
  def change_role(user, role)
    membership = self.user_space_associations.find(:first,
                    :conditions => {:user_id => user.id})
    membership.update_attributes({:role_id => role.id})
  end

  def publish!
    self.published = 1
    self.save
  end

  def unpublish!
    self.published = 0
    self.save
  end

  # Cria um forum logo após a criação do space através do callback after_create
  def create_forum
    Forum.create(:name => "Fórum da disciplina #{self.name}",
                 :description => "Este fórum pertence a disciplina " + \
                 "#{self.name}. " + \
                 "Apenas os participantes desta disciplina podem " + \
                 "visualizá-lo. Troque ideias, participe!",
                 :space_id => self.id)
  end

  # Após a criação do space, todos os usuários do course ao qual
  # o space pertence tem que ser associados ao space
  def create_space_association_for_users_course

    course_users = UserCourseAssociation.all(
      :conditions => {:state => 'approved', :course_id => self.course })

    course_users.each do |assoc|
      UserSpaceAssociation.create({:user => assoc.user,
                                  :space => self,
                                  :status => "approved",
                                  :role_id => assoc.role_id})
    end

  end

  #FIXME Remover quando a criação deixar de ser Wizard
  def enable_correct_validation_group!
    self.enable_validation_group(self.current_step.to_sym)
  end

end
