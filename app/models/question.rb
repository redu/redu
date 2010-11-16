class Question < ActiveRecord::Base

  before_save :set_answer_id

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
  validates_presence_of :answer_id
  validates_associated :alternatives
  validates_length_of :alternatives, :allow_nil => false, :within => 1..7

  def set_answer_id # answer id vem como o indice
    if self.alternatives and answer_id.to_i < self.alternatives.length and not self.alternatives[0].new_record?
      self.answer_id = self.alternatives[answer_id.to_i].id
    end
  end

end
