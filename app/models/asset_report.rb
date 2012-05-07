class AssetReport < ActiveRecord::Base
  # Modelo intermediário que especifica que um User finalizou uma determinada
  # Lecture dentro de um subject.

  belongs_to :enrollment # existe por questões de otimização
  belongs_to :lecture
  belongs_to :subject

  scope :done, where(:done => true)
  scope :of_subject, lambda { |subject_id| where(:subject_id => subject_id) }
  scope :of_user, lambda { |user_id|
    joins(:enrollment).where("enrollments.user_id = ?", user_id)
  }
end
