class Subject < ActiveRecord::Base
  belongs_to :space
  belongs_to :owner, :class_name => "User", :foreign_key => :user_id
  has_many :lectures, :order => "position", :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  has_many :members, :through => :enrollments, :source => :user,
    :dependent => :destroy
  has_many :graduated_members, :through => :enrollments, :source => :user,
    :include => :student_profiles,
    :conditions => ["student_profiles.graduaded = 1"]

  attr_protected :owner, :published

  acts_as_taggable

  validates_presence_of :title
  validates_size_of :description, :within => 30..200
  validates_length_of :lectures, :minimum => 1, :on => :update

  # Matricula o usuário com o role especificado. Retorna true ou false
  # dependendo do resultado
  def enroll(user, role = Role[:member])
    enrollment = self.enrollments.create(:user => user, :role_id => role.id)
    enrollment.valid?
  end

  # Desmatricula o usuário e retorna o mesmo
  def unenroll(user)
    self.members.delete(user)
  end
end
