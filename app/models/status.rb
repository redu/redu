# -*- encoding : utf-8 -*-
class Status < ActiveRecord::Base
  belongs_to :statusable, :polymorphic => true
  belongs_to :logeable, :polymorphic => true
  belongs_to :user
  has_many :answers, :as => :in_response_to,
    :dependent => :delete_all,
    :order => "created_at ASC",
    :include => [:user]
  has_many :users, :through => :status_user_associations
  has_many :status_user_associations, :dependent => :delete_all
  has_many :status_resources, :dependent => :delete_all

  accepts_nested_attributes_for :status_resources
  validates_associated :status_resources
  validates :type, :inclusion => {
    :in => %w(Status Activity Help Answer Log CompoundLog)
  }

  scope :activity_by_user, lambda { |u|
    where("type = ? AND user_id = ?", "Activity", u) }
  scope :helps_and_activities, where("type = ? OR type = ?", "Help", "Activity")
  scope :by_statusable, lambda { |kind, id| where("statusable_id IN (?) AND statusable_type = ?", id, kind.to_s) }
  scope :by_day, lambda { |day| where(:created_at =>(day..(day+1))) }
  scope :by_id, lambda { |id| where(:id =>id) }
  scope :not_compound_log, where("statuses.type NOT LIKE ?", "CompoundLog")

  scope :from_hierarchy, lambda { |c|
    where(build_conditions(c)).includes(:user) \
      .order("updated_at DESC")
  }

  # Não utilizar o recent em consultas sem include e posteriormente,
  # na view, fazer as consultas
  scope :recent_from_hierarchy, lambda { |c|
    where(build_conditions(c)).where('created_at > ?', 1.week.ago)
  }

  # Retorna apenas status visíveis
  scope :visible, where(:compound => false)

  class << self
    def find_and_include_related(*args)
      included = { include: \
                   [{ answers: [:user, :status_resources] }, :status_resources]}

      options = included.merge(args.extract_options!)
      find(args.first, options)
    end
  end
  # Constrói as condições de busca de status dentro da hierarquia. Aceita
  # Course, Space e Lecture como raiz
  def self.build_conditions(entity)
    statusables = statuables_on_hierarchy(entity)
    conditions = []

    statusables.each do |key, val|
      next if val.empty?

      ids = val.collect { |s| s.id }.join(',')
      conditions << "(statusable_type LIKE '#{key.to_s.classify}' AND " + \
        "statusable_id IN (#{ids}))"
    end

    return conditions.join(" OR ")
  end

  # Associa self à lista de usuários
  def associate_with(users)
    users.includes(:status_user_associations).each do |u|
      u.status_user_associations.create(:status => self)
    end
  end

  def self.associate_with(status, users)
    ids = \
      users.is_a?(ActiveRecord::Relation) ? users.value_of(:id) : users.map(&:id)

    columns = [:user_id, :status_id]
    options = { :validate => false, :on_duplicate_key_update => [:user_id] }
    values = ids.map { |user_id| [user_id, status.id] }

    StatusUserAssociation.import(columns, values, options)
  end

  def answers_ids(id)
    answers.where("user_id = ?", id).collect{ |answer| answer.id }
  end

  protected

  def self.statuables_on_hierarchy(root)
    groups = { :courses => [], :spaces => [], :lectures => [] }

    case root.class.to_s
    when 'Course'
      groups[:courses] = [root]
      groups[:spaces] = root.spaces.select("spaces.id")
      groups[:lectures] = lectures_or_nothing(groups[:spaces])
    when 'Space'
      groups[:spaces] = [root]
      groups[:lectures] = lectures_or_nothing(groups[:spaces])
    when 'Lecture'
      groups[:lectures] = [root]
    end

    groups
  end

  def self.lectures_or_nothing(spaces)
    spaces.collect do |space|
      space.lectures.select("lectures.id")
    end.flatten
  end
end
