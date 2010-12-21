class Question < ActiveRecord::Base
  # Associations
  has_many :alternatives, :dependent => :destroy
  has_many :question_exam_associations
  has_many :exams, :through => :question_exam_associations
  belongs_to :answer , :class_name => "Alternative", :foreign_key => "answer_id"
  belongs_to :author , :class_name => "User" , :foreign_key => "author_id"

  accepts_nested_attributes_for :alternatives,
    :reject_if => lambda { |q| q[:statement].blank? },
    :allow_destroy => true

  named_scope :public, :conditions => ['public = ?', true]

  # Validations
  validates_presence_of :statement
  validates_associated :alternatives
  validates_length_of :alternatives, :allow_nil => false, :within => 1..7
  validate :one_alternative_correct

  # Seta a resposta correta (não salva)
  def set_answer!
    correct = self.alternatives.find(:first, :conditions => {:correct => true})
    self.answer = correct
    self.save!
  end

  private

  # Verifica que pelo menos uma Alternativa está correta no contexto de Question
  def one_alternative_correct
    corrects = self.alternatives.collect { |a| a.correct? }
    xor = corrects.reduce(:^)

    self.errors.add_to_base("Pelo menos uma alternativa deve ser " + \
                            " verdadeira") if not xor
  end
end
