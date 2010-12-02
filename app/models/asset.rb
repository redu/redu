class Asset < ActiveRecord::Base
  belongs_to :subject
  belongs_to :assetable, :polymorphic => true
  belongs_to :lazy_asset

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
end
