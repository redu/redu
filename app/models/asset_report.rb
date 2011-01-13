class AssetReport < ActiveRecord::Base
  # Modelo intermediário que especifica que um User finalizou uma determinada
  # Lecture dentro de um subject.

  belongs_to :student_profile
  belongs_to :lecture
  belongs_to :subject
end
