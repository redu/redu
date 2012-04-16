class Enrollment < ActiveRecord::Base
  # Entidade intermediária entre User e Subject. É criada quando o usuário se
  # matricula num determinado Subject.
  # Contém informações sobre aulas realizadas, porcentagem do Subject cursado
  # e informações sobre desempenho no Subject.

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
    else
      self.graduaded = false
    end
    self.save

    return self.grade
  end

  protected

  def create_assets_reports
    subject.lectures.each do |lecture|
      self.asset_reports << AssetReport.create(:subject => self.subject,
                                                :lecture => lecture)
    end
  end
end
