class StudentProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject
  belongs_to :asset
  has_many :assets, :through => :asset_report
  has_many :asset_reports, :dependent => :destroy

  validates_uniqueness_of :user_id, :scope => :subject_id

  # Atualiza a porcentagem de cumprimento do módulo. Quando não houver mais recursos
  # a serem cursados, retorna false.
  def update_grade!
    total = self.subject.asset_reports.count(:conditions => {
      :subject_id => self.subject})
    done = self.subject.asset_reports.count(:conditions => {
      :subject_id => self.subject,
      :done => true})

    self.grade = ( done.to_f * 100 ) / total

    if total == done
      self.grade = 100
      self.graduaded = true
    end
    self.save

    return self.grade
  end
end
