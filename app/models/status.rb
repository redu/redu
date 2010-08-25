class Status < ActiveRecord::Base
  
  STATUS = 0
  QUESTION = 1
  POLL = 2
  ANSWER = 3
  
  belongs_to :statusable, :polymorphic => true
  
  belongs_to :in_response_to, :polymorphic => true
  belongs_to :user
  has_many :statuses, :as => :in_response_to
  
  acts_as_taggable
  
  validates_presence_of :text
  validates_inclusion_of :kind, 
    :in => [0, 1, 2, 3, 4],
    :message => "Tipo inválido"
  
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
    
  def Status.friends_statuses(user, limit = 0, offset = 20)
    sql = "SELECT s.* FROM statuses s, followship f " + \
      "WHERE (f.followed_by_id = #{user.id} " + \
      "AND s.user_id = f.follows_id) " + \
      "OR s.user_id = #{user.id} " + \
      "ORDER BY s.created_at DESC "
          
    Status.find_by_sql(sql)
  end
  
  def Status.group_statuses(group)
    sql = "SELECT s.* FROM statuses s, user_school_associations a " + \
      "WHERE a.school_id = #{group.id} " + \
      "AND s.user_id = a.user_id " + \
      "ORDER BY s.created_at DESC "
      
    Status.find_by_sql(sql)
  end
  
end
