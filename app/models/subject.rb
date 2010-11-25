class Subject < ActiveRecord::Base

  #associations
  has_many :assets
  has_many :lazy_assets
  has_many :enrollments, :dependent => :destroy
  has_many :statuses, :as => :statusable
  has_many :students, :through => :enrollments, :source => :user, :conditions => [ "enrollments.role_id = ?", 7 ]
  has_many :teachers, :through => :enrollments, :source => :user, :conditions => [ "enrollments.role_id = ?", 6 ]
  has_many :student_profiles, :dependent => :destroy
  belongs_to :owner, :class_name => "User" , :foreign_key => "user_id"
  belongs_to :space
  accepts_nested_attributes_for :lazy_assets,
    :reject_if => lambda { |lazy_asset| lazy_asset[:name].blank? or
      lazy_asset[:lazy_type].blank? }, :allow_destroy => true

  # METODOS DO WIZARD
  attr_writer :current_step

  # PLUGINS
  acts_as_taggable
  ajaxful_rateable :stars => 5
  has_attached_file :avatar, {
    :styles => { :thumb => "100x100>", :nano => "24x24>",
      :default_url => "/images/:class/missing_pic.jpg"}
  }

  #validations
  validates_presence_of :title, :if => lambda {|s| s.current_step == "subject"}
  validates_presence_of :description, :if => lambda {|s| s.current_step == "subject"}
  validates_presence_of :lazy_assets, :if => lambda {|s| s.current_step == "lecture"}

  validation_group :subject, :fields => [:title, :description]
  validation_group :lecture, :fields => [:lazy_assets]

  def to_param #friendly url
    "#{id}-#{title.parameterize}"
  end

  def permalink
    APP_URL + "/subjects/"+ self.id.to_s+"-"+self.title.parameterize
  end

  def recent_activity(limit = 0, offset = 20) #TODO colocar esse metodo em status passando apenas o objeto
    page = limit.to_i/10 + 1
    self.statuses.descend_by_created_at.paginate(:per_page => offset, :page =>page)
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

  def create_lecture_subject_type_lecture aulas, subject_id, current_user

    #positions tem funcionalidade efetiva na hora de atualizar as aulas, pois existe há possibilidade inserir uma aula numa ordem qualquer
    positions = aulas.map{|a| aulas.index(a.to_s)}

    clone_content(aulas, subject_id, current_user,positions)

  end


  def update_lecture_subject_type_lecture aulas, subject_id, current_user

    aulas_futuras =   aulas.nil? ? Array.new : aulas.map{|a| a.to_i}  #aulas selecionadas na tela, há um operador ternário
    #caso o usuario deschecar todas aulas ou nao houver aula associoda ao curso

    subject = current_user.subjects.find(subject_id) # meu current curso
    aulas_ids = subject.aulas.map{|a| a.id} # aulas relaciondas com o curso
    deleted_ids =  aulas_ids - aulas_futuras # aulas q serao deletadas
    inserted_ids = aulas_futuras - aulas_ids #aulas q serao inseridas

    Asset.destroy_all(:assetable_id => deleted_ids) unless deleted_ids.empty?#segurança ok, pois o array deleted_ids eh criado a partir do current_user

    #positions setadas de acordo com a ordem do usuário.
    positions = inserted_ids.map{|a| aulas.index(a.to_s)}

    clone_content(inserted_ids,subject_id,current_user,positions)

    #######rearrange courses###########
    subject = current_user.subjects.find(subject_id) #atualizado
    aulas_ids = subject.aulas.map{|a| a.id} # aulas relaciondas com o curso, atualizado.
    rearrange_lecture(subject, aulas_ids, aulas_futuras)

  end

  def update_lecture_subject_type_exam exams, subject_id, current_user

    exams_futuras =   exams.nil? ? Array.new : exams.map{|a| a.to_i}  #aulas selecionadas na tela, há um operador ternário
    #caso o usuario deschecar todas aulas ou nao houver aula associoda ao curso

    subject = current_user.subjects.find(subject_id) # meu current curso

    exames_ids = subject.exames.map{|a| a.id} # aulas relaciondas com o curso
    deleted_ids =  exames_ids  - exams_futuras # aulas q serao deletadas
    inserted_ids = exams_futuras-  exames_ids #aulas q serao inseridas

    Asset.destroy_all(:assetable_id => deleted_ids) unless deleted_ids.empty?#segurança ok, pois o array deleted_ids eh criado a partir do current_user


    unless inserted_ids.empty?
      inserted_ids.each do |exame_id|

        exame = current_user.exams.find(exame_id) #find the course by id
        clone_exame = exame.clone #clone it
        clone_exame.is_clone = true
        clone_exame.save#and save it
        asset = Asset.new
        asset.subject_id = subject_id
        asset.assetable_id = clone_exame.id
        asset.assetable_type = "Exam"
        asset.save
      end

    end
  end

  def create_lecture_subject_type_lecture aulas, subject_id, current_user

    aulas.each do |aula|
      lecture = current_user.lectures.find(aula) #find the lecture by id
      clone_lecture = lecture.clone #clone it
      clone_lecture.is_clone = true
      clone_lecture.save#and save it
      asset = Asset.new
      asset.subject_id = subject_id
      asset.assetable_id = clone_lecture.id
      asset.assetable_type = "Lecture"
      asset.save
    end

  end

  def create_lecture_subject_type_exam exams, subject_id

    exams.each do |exam_id|
      asset = Asset.new
      asset.subject_id = subject_id
      asset.assetable_id = exam_id
      asset.assetable_type = "Exam"
      asset.save
    end

  end

  def aulas
    self.assets.select{|asset| asset.assetable_type.eql?("Lecture")}.map{|a| a.assetable}
  end

  def exames
    self.assets.select{|asset| asset.assetable_type.eql?("Exam")}.map{|e| e.assetable}
  end

  def enrolled_students
    self.enrollments.map{|e| e.user}
  end

  def under_graduaded_students
    self.student_profiles.select{|sp| sp.graduaded == 0 }.map{|e| e.user}
  end

  def graduaded_students
    self.student_profiles.select{|sp| sp.graduaded == 1 }.map{|e| e.user}
  end

  def not_graduaded_students
    self.student_profiles.select{|sp| sp.graduaded == -1 }.map{|e| e.user}
  end

  protected

  def clone_content(aulas, subject_id, current_user, positions)

    aulas.each_with_index do |aula,index|

      lecture = current_user.lectures.find(aula)
      clone_lecture = lecture.clone :except => [:view_count, :created_at, :updated_at]#clone it, methodo 'except' relacionado com o plugin vendor/deep_cloning, sem os atributos[view_count, :created_at, :updated_at]

      #### clone o conteúdo da aula #######
      type = lecture.lectureable #a aula, pode ser seminar, page or interactive_class

      if type.class.to_s.eql?("InteractiveClass") #INTERACTIVE CLASS

        clone_type = InteractiveClass.find(type.id).clone :include => :lessons
        clone_type.save

        clone_type.lessons.each do |l| # um lesson pode ser 'Page' or 'Seminar',
          clone_lesson = Lesson.find(l.id)

          #salva as aulas interativas...
          if   l.lesson.class.to_s.eql?("Page")
            clone_lessonable = Page.find(l.lesson).clone
            clone_lessonable.save
          else
            clone_lessonable = Seminar.find(l.lesson).clone
            clone_lessonable.send(:create_without_callbacks) ##metodo do proprio active record para pular callback
          end

          clone_lesson.lesson_id = clone_lessonable.id
          clone_lesson.save
        end

      elsif type.class.to_s.eql?("Seminar") #SEMINAR

        clone_type = Seminar.find(type.id).clone
        clone_type.send(:create_without_callbacks) ##metodo do proprio active record para pular callback

      else #Page
        clone_type = type.clone
        clone_type.save
      end

      clone_lecture.lectureable_type = clone_type.class.to_s
      clone_lecture.lectureable_id = clone_type.id
      ##### fim do clone do conteúdo da aula######

      clone_lecture.is_clone = true
      clone_lecture.save#and save it

      asset = Asset.new
      asset.subject_id = subject_id
      asset.assetable_id = clone_lecture.id
      asset.position = positions[index] #variavel index eh contador
      asset.assetable_type = "Lecture"
      asset.save
    end

  end

  def rearrange_lecture(subject, aulas_ids, aulas_futuras)
    compare = aulas_futuras <=> aulas_ids

    if compare != 0
      aulas_futuras.each_with_index do |item, index|

        obj = subject.aulas.detect{|a| a.id == item}
        unless obj.nil?
          aux = Course.find(obj.id).lecture_subjet
          aux.position = index
          aux.save
        end
      end
    end #if

  end
end
