class Asset < ActiveRecord::Base
  belongs_to :subject
  belongs_to :assetable, :polymorphic => true
  belongs_to :lazy_asset
  has_many :student_profiles, :through => :asset_report
  has_many :asset_reports, :dependent => :destroy

  named_scope :lectures, :conditions => { :assetable_type => "Lecture" }
  named_scope :exams, :conditions => { :assetable_type => "Exam" }

  # Nome amigável para o tipo de asset
  def friendly_type
    case self.assetable_type
    when "Exam" then "Exame"
    when "Lecture"
      case self.assetable.lectureable_type
      when "Seminar" then "Vídeo-aula"
      when "InteractiveClass" then "Aula interativa"
      when "Page" then "Tutorial"
      end
    end
  end

  # Retorna o próximo Asset (self.position + 1) se houver
  def next
    self.subject.assets.find(:first, :conditions => {:position => self.position + 1})
  end
end
