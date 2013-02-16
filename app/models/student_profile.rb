class StudentProfile < ActiveRecord::Base
  # Perfil de um User num determinado Subject. Contém informações sobre aulas
  # realizadas, porcentagem do Subject cursado e informações sobre desempenho
  # no Subject.
  include VisClient

  after_create :creates_assets_reports

  belongs_to :user
  belongs_to :subject
  belongs_to :enrollment
  has_many :asset_reports, :dependent => :destroy
  has_many :lectures, :through => :asset_reports

  scope :of_subject, lambda { |subject_id| where(:subject_id => subject_id) }


  validates_uniqueness_of :user_id, :scope => :subject_id

  # Atualiza a porcentagem de cumprimento do módulo.
  # Quando não houver mais recursos
  # a serem cursados, retorna false.
  def update_grade!
    total = self.asset_reports.of_subject(self.subject).count
    done = self.asset_reports.of_subject(self.subject).where(:done => true).
            count

    self.grade = (( done.to_f * 100 ) / total)
    if total == done
      self.grade = 100
      self.graduated = true

      params = {
        :user_id => self.user_id,
        :lecture_id => nil,
        :subject_id => self.subject_id,
        :space_id => self.subject.space.id,
        :course_id => self.subject.space.course.id,
        :type => "subject_finalized",
        :status_id => nil,
        :statusable_id => nil,
        :statusable_type => nil,
        :in_response_to_id => nil,
        :in_response_to_type => nil,
        :created_at => self.created_at,
        :updated_at => self.updated_at
      }

      #self.send_async_info(params, Redu::Application.config.vis_client[:url])
    end
    self.save

    return self.grade
  end

  protected
  def creates_assets_reports
    subject.lectures.each do |lecture|
      self.asset_reports << AssetReport.create(:subject => self.subject,
                                                :lecture => lecture)
    end
  end
end
