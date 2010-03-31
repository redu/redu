class User < ActiveRecord::Base
  MALE    = 'M'
  FEMALE  = 'F'
  attr_accessor :password
  attr_protected :admin, :featured, :role_id
  
  
  ajaxful_rater
  
  acts_as_taggable  
  acts_as_commentable
  has_private_messages
 
  
  #callbacks  
  before_save   :encrypt_password, :whitelist_attributes
  before_create :make_activation_code 
  #before_create :activate_before_save #not necessary
  after_create  :update_last_login
 
  #after_save    :activate # <- ja começa ativo
  after_create {|user| UserNotifier.deliver_signup_notification(user) }
  #after_save   {|user| UserNotifier.deliver_activation(user) if user.recently_activated? }  
  
  before_save   :generate_login_slug
  after_save    :recount_metro_area_users
  after_destroy :recount_metro_area_users


  #validation
  validates_presence_of     :login, :email, :first_name, :last_name
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 5..20, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :metro_area,                 :if => Proc.new { |user| user.state }
  validates_length_of       :login,    :within => 5..20
  validates_length_of       :email,    :within => 3..100
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9A-Z]+\.)+[a-zA-Z]{2,})$/
  validates_format_of       :login, :with => /^[\sA-Za-z0-9_-]+$/
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_uniqueness_of   :login_slug
  validates_exclusion_of    :login, :in => AppConfig.reserved_logins
  validates_date :birthday, :before => 13.years.ago.to_date  
  
  #REGISTER
  validates_acceptance_of :tos, :message => "Você precisa aceitar os Termos de Uso"
  
  # ANNOTATIONS
  has_many :annotations, :dependent => :destroy
   
   # PROFILE
  has_one :profile
 
  # COMPETENCES
  has_many :user_competences, :dependent => :destroy
  has_many :competences, :class_name => "Skill", :source => :skill, :foreign_key => "skill_id", :through => :user_competences
 
  # SCHOOL
  has_many :user_school_association, :dependent => :destroy
  has_many :schools, :through => :user_school_association
  
  has_many :schools_owned, :class_name => "School" , :foreign_key => "owner"
  
  # SUBJECT
  has_many :user_subject_association
  has_many :subjects, :through => :user_subject_association
  
  # FOLLOWSHIP
  has_and_belongs_to_many :follows, :class_name => "User", :join_table => "followship", :association_foreign_key => "follows_id", :foreign_key => "followed_by_id", :uniq => true
  has_and_belongs_to_many :followers, :class_name => "User", :join_table => "followship", :association_foreign_key => "followed_by_id", :foreign_key => "follows_id", :uniq => true
  
  #COURSES
  has_many :courses, :foreign_key => "owner"
  has_many :acquisitions, :as => :acquired_by
  
  #LOG
  has_many :logs, :dependent => :destroy

  #CREDIT
  has_many :credits

  #RESOURCES
  has_many :resources, :foreign_key => "owner_id"
  
  # EXAMS
  has_many :exams, :foreign_key => "owner_id"
  
  has_many :exam_users#, :dependent => :destroy
  has_many :exam_history, :through => :exam_users, :source => :exam
  
  # QUESTIONS
  has_many :questions, :foreign_key => :author_id
  
  # FAVORITES
  has_many :favorites, :order => "created_at desc", :dependent => :destroy
  
   # STATUS
  has_many :statuses, :as => :in_response_to
  
  #SUGGESTIONS
  has_many :suggestions

  
  
  # COMMUNITY ENGINE:

    has_enumerated :role  
    has_many :posts, :order => "published_at desc", :dependent => :destroy
    has_many :photos, :order => "created_at desc", :dependent => :destroy
    has_many :invitations, :dependent => :destroy
    has_many :offerings, :dependent => :destroy
    has_many :rsvps, :dependent => :destroy

    #friendship associations
    has_many :friendships, :class_name => "Friendship", :foreign_key => "user_id", :dependent => :destroy
    has_many :accepted_friendships, :class_name => "Friendship", :conditions => ['friendship_status_id = ?', 2]
    has_many :pending_friendships, :class_name => "Friendship", :conditions => ['initiator = ? AND friendship_status_id = ?', false, 1]
    has_many :friendships_initiated_by_me, :class_name => "Friendship", :foreign_key => "user_id", :conditions => ['initiator = ?', true], :dependent => :destroy
    has_many :friendships_not_initiated_by_me, :class_name => "Friendship", :foreign_key => "user_id", :conditions => ['initiator = ?', false], :dependent => :destroy
    has_many :occurances_as_friend, :class_name => "Friendship", :foreign_key => "friend_id", :dependent => :destroy

    #forums
    has_many :moderatorships, :dependent => :destroy
    has_many :forums, :through => :moderatorships, :order => 'forums.name'
    has_many :sb_posts, :dependent => :destroy
    has_many :topics, :dependent => :destroy
    has_many :monitorships, :dependent => :destroy
    has_many :monitored_topics, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :order => 'topics.replied_at desc', :source => :topic

    belongs_to  :avatar, :class_name => "Photo", :foreign_key => "avatar_id"
    belongs_to  :metro_area
    belongs_to  :state
    belongs_to  :country
    has_many    :comments_as_author, :class_name => "Comment", :foreign_key => "user_id", :order => "created_at desc", :dependent => :destroy
    has_many    :comments_as_recipient, :class_name => "Comment", :foreign_key => "recipient_id", :order => "created_at desc", :dependent => :destroy
    has_many    :clippings, :order => "created_at desc", :dependent => :destroy
    has_many    :favorites, :order => "created_at desc", :dependent => :destroy
    
  #named scopes
  named_scope :recent, :order => 'users.created_at DESC'
  named_scope :featured, :conditions => ["users.featured_writer = ?", true]
  named_scope :active, :conditions => ["users.activated_at IS NOT NULL"]  
  named_scope :vendors, :conditions => ["users.vendor = ?", true]
  named_scope :tagged_with, lambda {|tag_name|
    {:conditions => ["tags.name = ?", tag_name], :include => :tags}
  }
  
  

  ## Class Methods

  # override activerecord's find to allow us to find by name or id transparently
  def self.find(*args)
    if args.is_a?(Array) and args.first.is_a?(String) and (args.first.index(/[a-zA-Z\-_]+/) or args.first.to_i.eql?(0) )
      find_by_login_slug(args)
    else
      super
    end
  end
  
  def self.find_country_and_state_from_search_params(search)
    country     = Country.find(search['country_id']) if !search['country_id'].blank?
    state       = State.find(search['state_id']) if !search['state_id'].blank?
    metro_area  = MetroArea.find(search['metro_area_id']) if !search['metro_area_id'].blank?

    if metro_area && metro_area.country
      country ||= metro_area.country 
      state   ||= metro_area.state
      search['country_id'] = metro_area.country.id if metro_area.country
      search['state_id'] = metro_area.state.id if metro_area.state      
    end
    
    states  = country ? country.states.sort_by{|s| s.name} : []
    if states.any?
      metro_areas = state ? state.metro_areas.all(:order => "name") : []
    else
      metro_areas = country ? country.metro_areas : []
    end    
    
    return [metro_areas, states]
  end

  def self.prepare_params_for_search(params)
    search = {}.merge(params)
    search['metro_area_id'] = params[:metro_area_id] || nil
    search['state_id'] = params[:state_id] || nil
    search['country_id'] = params[:country_id] || nil
    search['skill_id'] = params[:skill_id] || nil    
    search
  end
  
  def self.build_conditions_for_search(search)
    cond = Caboose::EZ::Condition.new

    cond.append ['activated_at IS NOT NULL ']
    if search['country_id'] && !(search['metro_area_id'] || search['state_id'])
      cond.append ['country_id = ?', search['country_id'].to_s]
    end
    if search['state_id'] && !search['metro_area_id']
      cond.append ['state_id = ?', search['state_id'].to_s]
    end
    if search['metro_area_id']
      cond.append ['metro_area_id = ?', search['metro_area_id'].to_s]
    end
    if search['login']    
      cond.login =~ "%#{search['login']}%"
    end
    if search['vendor']
      cond.vendor == true
    end    
    if search['description']
      cond.description =~ "%#{search['description']}%"
    end    
    cond
  end  
  
#  def self.find_by_activity(options = {})
#    options.reverse_merge! :limit => 30, :require_avatar => true, :since => 7.days.ago   
#    #Activity.since.find(:all,:select => Activity.columns.map{|column| Activity.table_name + "." + column.name}.join(",")+', count(*) as count',:group => Activity.columns.map{|column| Activity.table_name + "." + column.name}.join(","),:order => 'count DESC',:joins => "LEFT JOIN users ON users.id = activities.user_id" )
#    #Activity.since(7.days.ago).find(:all,:select => 'activities.user_id, count(*) as count',:group => 'activities.user_id',:order => 'count DESC',:joins => "LEFT JOIN users ON users.id = activities.user_id" )
#    activities = Activity.since(options[:since]).find(:all, 
#      :select => 'activities.user_id, count(*) as count', 
#      :group => 'activities.user_id', 
#      :conditions => "#{options[:require_avatar] ? ' users.avatar_id IS NOT NULL' : nil}", 
#      :order => 'count DESC', 
#      :joins => "LEFT JOIN users ON users.id = activities.user_id",
#      :limit => options[:limit]
#      )
#    activities.map{|a| find(a.user_id) }
#  end  
    
  def self.find_featured
    self.featured
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    # hide records with a nil activated_at
    u = find :first, :conditions => ['login = ?', login]
    u = find :first, :conditions => ['email = ?', login] if u.nil?
    u && u.authenticated?(password) && u.update_last_login ? u : nil
  end
  
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def self.paginated_users_conditions_with_search(params)
    search = prepare_params_for_search(params)

    metro_areas, states = find_country_and_state_from_search_params(search)
    
    cond = build_conditions_for_search(search)
    return cond, search, metro_areas, states
  end  

  
#  def self.recent_activity(page = {}, options = {})
#    page.reverse_merge! :size => 10, :current => 1
#    Activity.recent.find(:all, :page => page, *options)      
#  end

  def self.currently_online
    User.find(:all, :conditions => ["sb_last_seen_at > ?", Time.now.utc-5.minutes])
  end
  
  def self.search(query, options = {})
    with_scope :find => { :conditions => build_search_conditions(query) } do
      find :all, options
    end
  end
  
  def self.build_search_conditions(query)
    query
  end  
  
  def self.opensocial_id_column_name; 'id'; end
  def title; self.display_name; end
  
  
  ## End Class Methods  
  
  
  ## Instance Methods
  def can_manage(entity)
    return true if self.admin?
    
    case entity.class 
    when 'Course'
      (self.school_admin?(entity) || entity.owner == self)    
    end
  end
  
  
  def earn_points(activity)
    thepoints = AppConfig.points[activity]
    self.update_attribute(:score, self.score + thepoints)
  end
  
  def has_access_to_course(course)
    #TODO
    @acq = Acquisition.find(:first, :conditions => ['acquired_by_id = ? AND course_id = ?', self.id, course.id])
  end
  
  def moderator_of?(forum)
    moderatorships.count(:all, :conditions => ['forum_id = ?', (forum.is_a?(Forum) ? forum.id : forum)]) == 1
  end
  
  def monitoring_topic?(topic)
    monitored_topics.find_by_id(topic.id)
  end

  def to_xml(options = {})
    options[:except] ||= []
    super
  end
  
  def recount_metro_area_users
    return unless self.metro_area
    ma = self.metro_area
    ma.users_count = User.count(:conditions => ["metro_area_id = ?", ma.id])
    ma.save
  end  
  
  def to_param
    login_slug
  end
  
  def this_months_posts
    self.posts.find(:all, :conditions => ["published_at > ?", DateTime.now.to_time.at_beginning_of_month])
  end
  
  def last_months_posts
    self.posts.find(:all, :conditions => ["published_at > ? and published_at < ?", DateTime.now.to_time.at_beginning_of_month.months_ago(1), DateTime.now.to_time.at_beginning_of_month])
  end
  
  def avatar_photo_url(size = nil)
    if avatar
      avatar.public_filename(size)
    else
      case size
        when :thumb
          AppConfig.photo['missing_thumb']
        else
          AppConfig.photo['missing_medium']
      end
    end
  end

  def deactivate
    return if admin? #don't allow admin deactivation
    @activated = false
    update_attributes(:activated_at => nil, :activation_code => make_activation_code)
  end

  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
  end
  
  def active?
    activation_code.nil? or (self.created_at > (Time.now - 30.days))
  end

  def recently_activated?
    @activated
  end
  
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def valid_invite_code?(code)
    code == invite_code
  end
  
  def invite_code
    Digest::SHA1.hexdigest("#{self.id}--#{self.email}--#{self.salt}")
  end
  
  def location
    metro_area && metro_area.name || ""
  end
  
  def full_location
    "#{metro_area.name if self.metro_area}#{" , #{self.country.name}" if self.country}"
  end
  
  def reset_password
     new_password = newpass(8)
     self.password = new_password
     self.password_confirmation = new_password
     return self.valid?
  end

  def newpass( len )
     chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
     new_password = ""
     1.upto(len) { |i| new_password << chars[rand(chars.size-1)] }
     return new_password
  end
  
  def owner
    self
  end

  def staff?
    featured_writer?
  end
  
  def can_request_friendship_with(user)
    !self.eql?(user) && !self.friendship_exists_with?(user)
  end

  def friendship_exists_with?(friend)
    Friendship.find(:first, :conditions => ["user_id = ? AND friend_id = ?", self.id, friend.id])
  end
  
  # before filter
  def generate_login_slug
    self.login_slug = self.login.gsub(/[^a-z1-9]+/i, '-')
  end

  def update_last_login
    #self.track_activity(:logged_in) if self.last_login_at.nil? || (self.last_login_at && self.last_login_at < Time.now.beginning_of_day)
    self.update_attribute(:last_login_at, Time.now)
  end
  
  def add_offerings(skills)
    skills.each do |skill_id|
      offering = Offering.new(:skill_id => skill_id)
      offering.user = self
      if self.under_offering_limit? && !self.has_skill?(offering.skill)
        if offering.save
          self.offerings << offering
        end
      end
    end
  end  
  
  def under_offering_limit?
    self.offerings.size < 3
  end
  
  def has_skill?(skill)
    self.offerings.collect{|o| o.skill }.include?(skill)
  end

  def has_reached_daily_friend_request_limit?
    friendships_initiated_by_me.count(:conditions => ['created_at > ?', Time.now.beginning_of_day]) >= Friendship.daily_request_limit
  end

#  def network_activity(page = {}, since = 1.week.ago)
#    page.reverse_merge :size => 10, :current => 1
#    friend_ids = self.friends_ids
#    metro_area_people_ids = self.metro_area ? self.metro_area.users.map(&:id) : []
#    
#    ids = ((friends_ids | metro_area_people_ids) - [self.id])[0..100] #don't pull TOO much activity for now
#    
#    Activity.recent.since(since).by_users(ids).find(:all, :page => page)          
#  end

#  def comments_activity(page = {}, since = 1.week.ago)
#    page.reverse_merge :size => 10, :current => 1
#
#    Activity.recent.since(since).find(:all, 
#      :conditions => ['comments.recipient_id = ? AND activities.user_id != ?', self.id, self.id], 
#      :joins => "LEFT JOIN comments ON comments.id = activities.item_id AND activities.item_type = 'Comment'",
#      :page => page)      
#  end

  def friends_ids
    return [] if accepted_friendships.empty?
    accepted_friendships.map{|fr| fr.friend_id }
  end
  
  def recommended_posts(since = 1.week.ago)
    return [] if tags.empty?
    rec_posts = Post.find_tagged_with(tags.map(&:name), 
      :conditions => ['posts.user_id != ? AND published_at > ?', self.id, since ],
      :order => 'published_at DESC',      
      :limit => 10
      )

    if rec_posts.empty?
      []
    else
      rec_posts.uniq
    end
  end
  
  def display_name
    if self.first_name and self.last_name
      self.first_name + " " + self.last_name
    else
      login
    end
    
  end
  
  def admin?
    role && role.eql?(Role[:admin])
  end

  def moderator?
    role && role.eql?(Role[:moderator])
  end

  def member?
    role && role.eql?(Role[:member])
  end
  
  # school roles

  def get_association_with(school)
    association = UserSchoolAssociation.find(:first, :conditions => ['user_id = ? AND school_id = ?', self.id, school.id])
  end
  
  
  def teacher?(school)
    association = get_association_with school
    association && association.role && association.role.eql?(Role[:teacher])
  end
  
  def coodinator?(school)
    association = get_association_with school
    association && association.role && association.role.eql?(Role[:coodinator])
  end
  
  def school_admin?(school = nil)
    if school
      association = get_association_with school
      association && association.role && association.role.eql?(Role[:school_admin])
    else
      association = UserSchoolAssociation.find(:first, :conditions => ['user_id = ?', self.id])
      association && association.role && association.role.eql?(Role[:school_admin])
    end
  end
  
  def student?(school)
    association = get_association_with school
    association && association.role && association.role.eql?(Role[:student])
  end
  
  ## end
  
  
  def male?
    gender && gender.eql?(MALE)
  end
  
  def female
    gender && gender.eql?(FEMALE)    
  end
  
  ## End Instance Methods
  
  ### Métodos Adicionais 
    
  def recent_activity
    Log.find(:all, :conditions => ["user_id = ?", self.id], :order => "created_at DESC", :limit => 10)
  end
  
  def log_activity
    # a maneira correta de se fazer isso é via consulta no sql pois é muito mais rapido pq nao precisa ficar iterando
    
   sql =  "SELECT DISTINCT l.id, l.logeable_id, l.logeable_name, l.logeable_type, l.user_id, l.action, l.created_at FROM"
   sql += " users u, followship f, logs l WHERE"
   sql += " f.follows_id = '#{self.id}' AND l.user_id = f.followed_by_id ORDER BY created_at DESC LIMIT 0,5 "
  # sql += " AND l.created_at > '#{Time.now.utc-10.minutes}'"
   
   #TODO tempo?
    Log.find_by_sql(sql)
    
    #@follows = self.follows  
    #@logs = []
    #@follows.each do |follows|
    #  @logs += Log.find(:all, :conditions => ["user_id = ?", follows.id],:limit => 5, :order => 'created_at DESC') 
    #end
    #return @logs
  end
  
  def add_favorite(favoritable_type, favoritable_id)
   Favorite.create(:favoritable_type => favoritable_type, 
      :favoritable_id => favoritable_id, 
      :user_id => self.id)
  end
  
  def has_favorite(favoritable)
    Favorite.find(:first, :conditions => ["favoritable_id = ? AND favoritable_type = ? AND user_id = ?", favoritable.id, favoritable.class.to_s,self.id  ])
  end
  
  def get_favorites
    @favorites = Favorite.find(:all, :conditions => ["user_id = ?", self.id], :order => 'created_at DESC') 
  end
  
  def has_credits_for_course(course)
    @course_price = CoursePrice.find(:first, :conditions => ['course_id = ?', course.id]).price.to_f
    @user_credit = Credit.total(self.id).to_f - Acquisition.total(self.id).to_f
    (@user_credit >= @course_price)
  end
  


  protected
  
  #ADICIONADO PARA PASSAR O BUG DO 'after_save :activate'
    def activate_before_save
      self.activated_at = Time.now.utc
      self.activation_code = nil
    end

    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    # before filters
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def whitelist_attributes
      self.login = self.login.strip
      self.description = white_list(self.description )
      self.stylesheet = white_list(self.stylesheet )
    end
  
    def password_required?
      crypted_password.blank? || !password.blank?
  end
  
 
  
end
