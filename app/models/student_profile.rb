class StudentProfile < ActiveRecord::Base
  # Perfil de um User num determinado Subject. Contém informações sobre aulas
  # realizadas, porcentagem do Subject cursado e informações sobre desempenho
  # no Subject.

  belongs_to :user
  belongs_to :subject
  has_many :asset_reports, :dependent => :destroy
  has_many :lectures, :through => :asset_report

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

  def days_to_complete
    final = self.created_at + self.subject.duration.days
    final_date = Date.new(final.year, final.month, final.day)
    final_date - Date.today
  end
end
