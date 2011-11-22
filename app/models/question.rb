class UniqueTruthValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    alts = record.alternatives
    if alts.length > 1 && more_than_one_correct?(alts)
      record.errors[attribute] << "só pode existir uma alternativa correta"
    end
  end

  protected

  def more_than_one_correct?(value)
    remain_values = value.reject(&:marked_for_destruction?)
    remain_values.select(&:correct?).length > 1
  end
end

class Question < ActiveRecord::Base
  belongs_to :exercise
  has_many :alternatives, :dependent => :destroy
  has_many :choices, :dependent => :destroy
  has_one :correct_alternative, :class_name => 'Alternative',
    :foreign_key => :question_id, :conditions => { :correct => true }

  validates_presence_of :statement
  validates :alternatives, :unique_truth => true

  sortable :scope => :exercise_id

  accepts_nested_attributes_for :alternatives, :allow_destroy => true

  # Cria uma instância de Choice com o usuário e a alternativa especificada
  def choose_alternative(alternative, user)
    alt = find_alternative(alternative)
    choice = choices.find_or_initialize_by_user_id(user.id)
    choice.update_attributes({ :alternative_id => alt.id,
                               :correct => alt.correct? })

    choice
  end

  def choice_for(user)
    choices.first(:conditions => { :user_id => user.id })
  end

  protected

  def find_alternative(alternative_or_id)
    return alternative_or_id if alternative_or_id.is_a? Alternative
    alternatives.find(alternative_or_id)
  end
end
