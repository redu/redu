class Exam < ActiveRecord::Base

  # ASSOCIATIONS
  has_many :statuses, :as => :statusable
  has_many :question_exam_associations, :dependent => :destroy
  has_many :questions, :through => :question_exam_associations
  has_many :exam_users, :dependent => :destroy
  has_many :user_history, :through => :exam_users, :source => :user
  has_many :favorites, :as => :favoritable, :dependent => :destroy
  has_many :logs, :as => :logeable, :dependent => :destroy, :class_name => 'Status'
  has_many :assets, :as => :assetable
  belongs_to :owner , :class_name => "User" , :foreign_key => "owner_id"
  belongs_to :simple_category

  # NESTED
  accepts_nested_attributes_for :questions,
    :reject_if => lambda { |q| q[:statement].blank? },
    :allow_destroy => true

  # NAMED SCOPES
  named_scope :published, :conditions => ['published = ?', true], :include => :owner
  named_scope :published_by, lambda { |my_id|
    { :conditions => ["published = ? AND owner_id = ?", true, my_id] }
  }
  named_scope :unpublished_by, lambda { |my_id|
    { :conditions => ["published = ? AND owner_id = ?", false, my_id] }
  }

  # ACCESSORS
  attr_writer :current_step

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5

  # VALIDATIONS
  validates_presence_of :name
  validates_presence_of :description
  validates_length_of :questions, :allow_nil => false, :minimum => 1
  validates_associated :questions

  validation_group :general, :fields => [:name, :description]
  validation_group :editor, :fields => [:questions]
  validation_group :publication, :fields => [:price]

  def get_question(qid)
    if qid
      self.questions.each_with_index do |question, index|
        return [question,index]  if question.id == qid
      end
    end
  end

  def to_param #friendly url
    "#{id}-#{name.parameterize}"
  end

  def permalink
    APP_URL + "/exams/"+ self.id.to_s+"-"+self.name.parameterize
  end

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[general editor publication]
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

  def enable_correct_validation_group!
    self.enable_validation_group(self.current_step.to_sym)
  end
end
