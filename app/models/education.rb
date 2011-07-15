class Education < ActiveRecord::Base
  # Representa uma formação escolar/adadêmica do usuário, deste modo
  # faz parte do currículo do mesmo.
  # Possui as seguintes especializações: HighSchool (Ensino médio),
  # HigherEducation (Ensino Superior), ComplementaryCourse (Curso
  # Complementar) e EventEducation (Evento).

  belongs_to :educationable, :polymorphic => true, :dependent => :destroy
  belongs_to :user

  attr_protected :user

  validates_presence_of :educationable, :user
  validates_associated :educationable
end
