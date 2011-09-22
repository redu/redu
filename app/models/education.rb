class Education < ActiveRecord::Base
  # Representa uma formação escolar/adadêmica do usuário, deste modo
  # faz parte do currículo do mesmo.
  # Possui as seguintes especializações: HighSchool (Ensino médio),
  # HigherEducation (Ensino Superior), ComplementaryCourse (Curso
  # Complementar) e EventEducation (Evento).

  belongs_to :educationable, :polymorphic => true, :dependent => :destroy
  belongs_to :user
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  attr_protected :user

  validates_presence_of :educationable, :user
  validates_associated :educationable

  scope :high_schools, where("educationable_type LIKE 'HighSchool'")
  scope :higher_educations, where("educationable_type LIKE 'HigherEducation'")
  scope :complementary_courses, where("educationable_type LIKE 'ComplementaryCourse'")
  scope :event_educations, where("educationable_type LIKE 'EventEducation'")
end
