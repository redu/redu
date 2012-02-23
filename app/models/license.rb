class License < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :course

  validates_presence_of :name, :email, :period_start, :role, :course, :invoice
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  # Retorna todas as licenças que estão em uso
  scope :in_use, where(:period_end => nil)
  scope :of_course, lambda { |course|
    where(:course_id => course.id)
  }
  # Retorna todas as licenças consideradas pagáveis
  scope :payable, where(:role => Role[:member])
end
