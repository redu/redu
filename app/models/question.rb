class Question < ActiveRecord::Base
  belongs_to :exercise
  has_many :alternatives, :dependent => :destroy
  has_many :choices, :dependent => :destroy
  has_one :correct_alternative, :class_name => 'Alternative',
    :foreign_key => :question_id, :conditions => { :correct => true }

  validates_presence_of :statement

  sortable :scope => :exercise_id

  # Cria uma instância de Choice com o usuário e a alternativa especificada
  def choose_alternative(alternative, user)
    alt = find_alternative(alternative)
    choice = choices.find_or_initialize_by_user_id(user.id)
    choice.update_attributes({ :alternative_id => alt.id,
                               :correct => alt.correct? })

    choice
  end

  protected

  def find_alternative(alternative_or_id)
    return alternative_or_id if alternative_or_id.is_a? Alternative
    alternatives.find(alternative_or_id)
  end
end
