class Status < ActiveRecord::Base

  belongs_to :statusable, :polymorphic => true
  belongs_to :user
  has_many :answers, :as => :in_response_to
  has_many :observers, :through => :status_user_associations
  has_many :status_user_associations, :dependent => :destroy

  # def responses
  #   sql = "SELECT * FROM statuses s " + \
  #     "WHERE s.in_response_to_id = #{self.id} " + \
  #   "ORDER BY s.created_at DESC "

  #   Status.find_by_sql(sql)
  # end

  # Dada uma rede, retorna os status postados na mesma
  def Status.group_statuses(group)
    sql = "SELECT s.* FROM statuses s, user_space_associations a " + \
      "WHERE a.space_id = #{group.id} " + \
    "AND s.user_id = a.user_id " + \
      "ORDER BY s.created_at DESC "

    Status.find_by_sql(sql)
  end
end
