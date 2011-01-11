class Subject < ActiveRecord::Base
  belongs_to :space
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
  has_many :lectures, :dependent => :destroy
  has_many :members, :through => :enrollments, :source => :user
  has_many :graduated_members, :through => :enrollments, :source => :user
  has_many :enrollments

  validates_presence_of :title
  validates_size_of :description, :within => 30..200

  # Matricula o usuário com o role especificado. Retorna true ou false
  # dependendo do resultado
  def enroll(user, role = Role[:member])
    enrollment = self.enrollments.create(:user_id => user, :role_id => role.id)
    enrollment.create_student_profile(:user_id => user, :subject => self)

    enrollment.valid?
  end

  # Desmatricula o usuário e retorna o mesmo
  def unenroll(user)
    self.members.delete(user)
  end
end
