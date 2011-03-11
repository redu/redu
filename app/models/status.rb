class Status < ActiveRecord::Base

  STATUS = 0
  QUESTION = 1
  POLL = 2
  ANSWER = 3

  before_validation :enable_correct_validation_group

  belongs_to :statusable, :polymorphic => true
  belongs_to :logeable, :polymorphic => true
  belongs_to :in_response_to, :polymorphic => true
  belongs_to :user
  alias :owner :user
  has_many :statuses, :as => :in_response_to

  named_scope :not_response,
    { :conditions => ["kind <> #{Status::ANSWER} OR kind IS NULL"] }
  named_scope :home_activity, lambda {|user|
    { :conditions => ["(kind <> :answer OR kind is NULL) AND (((statusable_id IN (:spaces) AND statusable_type = 'Space') OR (logeable_id IN (:spaces) AND logeable_type = 'Space')) OR ((statusable_id IN (:subjects) AND statusable_type = 'Subject') OR (logeable_id IN (:subjects) AND logeable_type = 'Subject')) OR user_id = :user OR (user_id IN (:friends) AND statusable_type = 'User'))",
      {:spaces => user.spaces, :subjects => user.subjects, :user => user,
       :friends => user.friends, :answer => Status::ANSWER } ] }
  }
  named_scope :profile_activity, lambda {|user|
    { :conditions => ["(kind <> :answer OR kind is NULL) AND (user_id = :user OR (statusable_id = :user AND statusable_type = 'User'))",
      {:user => user, :answer => Status::ANSWER } ] }
  }
  acts_as_taggable

  validation_group :log, :fields => [] # Grupo para tipo log
  validation_group :status, :fields => [:text, :kind] # Grupo para tipo status (inclui question)

  validates_presence_of :text
  validates_inclusion_of :kind,
    :in => [0, 1, 2, 3, 4],
    :message => "Tipo inválido"
  validates_length_of :text, :maximum => 400

  # Inspects object attributes and decides which validation group to enable
  def enable_correct_validation_group
    if self.log
      self.enable_validation_group :log
    else
      self.enable_validation_group :status
    end
  end

  def status?
    self.kind == Status::STATUS
  end

  def question?
    self.kind == Status::QUESTION
  end

  def poll?
    self.kind == Status::POLL
  end

  def answer?
    self.kind == Status::Answer
  end

  def responses
    sql = "SELECT * FROM statuses s " + \
      "WHERE s.in_response_to_id = #{self.id} " + \
    "ORDER BY s.created_at DESC "

    Status.find_by_sql(sql)
  end

  #lista somente atividades (logs automaticos)
  def Status.activities(user)
    Status.all(:conditions => ["log = 1 AND user_id = ?", user.id])
  end

  # Dada uma rede, retorna os status postados na mesma
  def Status.group_statuses(group)
    sql = "SELECT s.* FROM statuses s, user_space_associations a " + \
      "WHERE a.space_id = #{group.id} " + \
    "AND s.user_id = a.user_id " + \
      "ORDER BY s.created_at DESC "

    Status.find_by_sql(sql)
  end
end
