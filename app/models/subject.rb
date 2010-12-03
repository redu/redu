class Subject < ActiveRecord::Base

  #associations
  has_many :assets, :order => :position, :dependent => :destroy
  has_many :lazy_assets, :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  has_many :statuses, :as => :statusable
  has_many :students, :through => :enrollments, :source => :user, :conditions => [ "enrollments.role_id = ?", 3 ]
  has_many :teachers, :through => :enrollments, :source => :user, :conditions => [ "enrollments.role_id = ?", 6 ]
  has_many :student_profiles, :dependent => :destroy
  has_many :asset_reports, :dependent => :destroy
  belongs_to :owner, :class_name => "User" , :foreign_key => "user_id"
  belongs_to :space

  accepts_nested_attributes_for :lazy_assets,
    :reject_if => lambda { |lazy_asset|
    if lazy_asset['existent'] == 'true'
      lazy_asset['assetable_id'].blank? &&
        lazy_asset['assetable_type'].blank?
    else
      lazy_asset['name'].blank? &&
        lazy_asset['lazy_type'].blank?
    end
  },
    :allow_destroy => true

  # METODOS DO WIZARD
  attr_writer :current_step

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  has_attached_file :avatar, {
    :styles => { :thumb => "100x100>", :nano => "24x24>",
      :default_url => "/images/:class/missing_pic.jpg"}
  }

  validates_presence_of :title, :description
  validates_length_of :lazy_assets, :allow_nil => false, :minimum => 1,
    :message => "O módulo precisar ter pelo menos um recurso"
  validates_associated :lazy_assets,
    :message => "Um ou mais erros ocorreram nos recursos"

  validation_group :subject, :fields => [:title, :description]
  validation_group :lecture, :fields => [:lazy_assets]

  def to_param #friendly url
    "#{id}-#{title.parameterize}"
  end

  def permalink
    APP_URL + "/subjects/"+ self.id.to_s+"-"+self.title.parameterize
  end

  def recent_activity(offset = 0, limit = 20) #TODO colocar esse metodo em status passando apenas o objeto
    self.statuses.all(:order => 'created_at DESC', :offset=> offset, :limit=> limit)
  end

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[subject lecture]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

  def enable_correct_validation_group!
    self.enable_validation_group(self.current_step.to_sym)
  end

  # Faz deep clone (i.e. inclusive as associações) de cada lazy_asset
  # com exitent = true
  def clone_existent_assets!
    cloned_assets = lazy_assets.existent.collect do |lazy|
      unless lazy.asset # Se já tiver sido clonado, não clona novamente.
        cloned = lazy.create_asset
        if cloned
          asset = Asset.new(:subject => self, :assetable => cloned)
          lazy.asset = asset
          lazy.save
          self.assets << asset
        end
      end
    end

    self.enable_validation_group(:lecture)
    self.random_order
    self.save
  end

  #TODO usar maquina de estados
  # Verifica se todos os lazy_assets foram criados
  def ready_to_be_published?
    self.lazy_assets.count == self.assets.count
  end

  # Altera a ordem dos recursos já finalizados.
  def change_assets_order
    redirect_to space_subject_path(@subject)
  end

  #TODO Verificar necessidade
  def enrolled_students
    self.enrollments.map{|e| e.user}
  end

  #TODO Verificar necessidade
  def under_graduaded_students
    self.student_profiles.select{|sp| sp.graduaded == 0 }.map{|e| e.user}
  end

  #TODO Verificar necessidade
  def graduaded_students
    self.student_profiles.select{|sp| sp.graduaded == 1 }.map{|e| e.user}
  end

  #TODO Verificar necessidade
  def not_graduaded_students
    self.student_profiles.select{|sp| sp.graduaded == -1 }.map{|e| e.user}
  end

  protected

  # Adiciona positions aos assets sem nenhum critério
  def random_order
    self.assets.each_with_index do |asset, index|
      asset.position = index + 1
      asset.save
    end
  end

end
