class Exercise < ActiveRecord::Base
  # Exercícios de multipla escolha. É um lectureable.
  #
  # exercise.start_for(user)
  #
  # q1 = exercise.questions.first
  # q1.choose_alternative(q1.alternatives.first, user)
  # q2 = q1.next_item
  # q2.choose_alternative(q2.alternatives.last, user)
  # q2.last_item?
  # => false
  #
  # result = exercise.finalize_for(user)
  # result.grade.round(2).to_s
  # => "6.67"
  # result.duration
  # => 0.691735982894897
  # result.to_report
  # => {:misses=>1, :blanks=>1, :duration=>0.691735982894897,
  #     :hits=>1, :grade=>#<BigDecimal:10d7cbfb0,'0.33...E1',45(72)>}

  has_many :questions, :dependent => :destroy
  has_many :results, :dependent => :destroy
  has_many :explained_questions,
    :conditions => 'questions.explanation IS NOT NULL',
    :class_name => 'Question', :foreign_key => :exercise_id
  has_one :lecture, :as => :lectureable

  accepts_nested_attributes_for :questions

  # Utiliza o maximum_grade para calcular o peso por questão
  def question_weight
    if questions.count == 0
      BigDecimal.new("0")
    else
      maximum_grade / BigDecimal.new(questions.count.to_s)
    end
  end

  # Média de nota no exercise
  def average_grade
    results.finalized.average(:grade) || BigDecimal.new('0')
  end

  # Inicia a contagem de tempo e corretude do exercício. Retorna uma instância
  # de Result no estado started.
  #  - Caso já exista um Result started ou waiting p/ o usuário um novo
  #  result é criado e o anterior é destruido.
  #  - Caso já exista um Result finalizado p/ o usuário, retorna esse result
  def start_for(user)
    result = results.find_or_initialize_by_user_id(:user_id => user.id)

    if result.new_record?
      result.save && result.start!
    else
      if result.started? || result.waiting?
        results.where(:user_id => user.id).destroy_all
        result = start_for(user)
      end
    end

    result
  end

  # Finaliza contagem de tempo e gera resultado para o usuário. Só funciona
  # caso o start_for(user) tenha sido chamado e um novo Result tenha sido
  # criado.
  def finalize_for(user)
    result = results.started.find(:first, :conditions => { :user_id => user.id })
    result.finalize! if result

    result
  end

  def finalized_by?(user)
    results.finalized.exists?(:user_id => user.id)
  end

  def choices_for(user)
    ids = questions.select('id').collect(&:id)
    Choice.where(:question_id => ids, :user_id => user.id)
  end

  def result_for(user, finalized=true)
    if finalized
      results.finalized.find(:first, :conditions => { :user_id => user.id })
    else
      results.find(:first, :conditions => { :user_id => user.id })
    end
  end

  def info
    { :questions_count => questions.count,
      :explained_count => explained_questions.count,
      :results_count => results.finalized.count,
      :average_grade => (results.finalized.average(:grade) || BigDecimal.new("0")),
      :average_duration => results.finalized.average(:duration) || 0,
    }
  end
end
