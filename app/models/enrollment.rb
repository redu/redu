class Enrollment < ActiveRecord::Base
  # Entidade intermediária entre User e Subject. É criada quando o usuário se
  # matricula num determinado Subject.
  # Contém informações sobre aulas realizadas, porcentagem do Subject cursado
  # e informações sobre desempenho no Subject.
  include VisClient

  # Em alguns casos o enrollment é chamado utilizando o gem activerecord-import
  # por questões de otimização. Este gem desabilita qualquer tipo de callback
  # cuidado ao adicionar callbacks a esta entidade.
  after_create :create_assets_reports

  belongs_to :user
  belongs_to :subject
  has_many :asset_reports, :dependent => :destroy
  has_many :lectures, :through => :asset_reports

  enumerate :role

  validates_uniqueness_of :user_id, :scope => :subject_id

  # FIXME Testar
  # Filtra por papéis (lista)
  scope :with_roles, lambda { |roles|
    unless roles.empty?
      where(:role => roles.flatten)
    end
  }

  # FIXME Testar
  # Filtra por palavra-chave (procura em User)
  scope :with_keyword, lambda { |keyword|
    if not keyword.empty? and keyword.size > 4
      where("users.first_name LIKE :keyword " + \
        "OR users.last_name LIKE :keyword " + \
        "OR users.login LIKE :keyword", {:keyword => "%#{keyword}%"})
    end
  }

  # Atualiza a porcentagem de cumprimento do módulo.
  def update_grade!
    total = self.asset_reports.count
    done = self.asset_reports.count(:conditions => "done = 1");

    self.grade = (( done.to_f * 100 ) / total)
    if total == done
      self.grade = 100
      self.graduaded = true
      notify_vis
    else
      self.graduaded = false
    end
    self.save

    return self.grade
  end

  def create_assets_reports
    subject.lectures.each do |lecture|
      self.asset_reports << AssetReport.create(:subject => self.subject,
                                               :lecture => lecture)
    end
  end

  protected

  def notify_vis
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

    self.send_async_info(params, Redu::Application.config.vis_client[:url])
  end
end
