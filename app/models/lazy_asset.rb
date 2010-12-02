class LazyAsset < ActiveRecord::Base
  belongs_to :subject
  belongs_to :assetable, :polymorphic => true
  has_one :asset, :dependent => :destroy
  has_one :lecture, :conditions => {:published => true}
  has_one :exam

  validates_presence_of :name, :lazy_type, :if => "self.existent == false",
    :message => "Nome e/ou tipo não informados"
  validates_presence_of :assetable_id, :assetable_type,
    :if => "self.existent == true",
    :messages => "Recurso inválido ou inexistente"
  validates_inclusion_of :assetable_type,
    :in => %w(Exam Lecture), :if => "self.existent == true",
    :message => "Tipo de recurso inválido"

  # Faz deep clone do assetable e retorna a nova instância
  # O assetable deve possuir o atributo booleano is_clone
  def create_asset
    return nil unless self.existent

    case self.assetable_type
    when Seminar.to_s
      #TODO Nos tipos Seminar, InteractiveClass e Page, passar Lecture
      clone = self.assetable.lecture.clone :include => :lectureable

      ActiveRecord::Base.transaction do
        #TODO workaround para o callback mal projetado truncate_youtube_url
        clone.is_clone = true
        clone.lectureable.send(:create_without_callbacks)
        clone.save
      end
    when Exam.to_s
      clone = self.assetable.clone :include => {:questions => :alternatives}
      clone.is_clone = true
      clone.save
      clone.set_answers! # Define resposta correta para cada questao
    else
      clone = self.assetable.clone
      clone.is_clone = true
      clone.save
    end
    return clone
  end

  def new_assetable
    self.try(:lecture) || self.try(:exam)
  end
end
