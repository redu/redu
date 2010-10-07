class Subject < ActiveRecord::Base


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
  # validates_presence_of :simple_category
  
  
  def validate
    if self.start_time != nil && self.end_time != nil
      errors.add :end_time, "Data final tem que ser maior do que data inical" if self.start_time > self.end_time
    end

  end

  #associations
  has_and_belongs_to_many :audiences
  has_many :course_subjects,:order =>"position", :dependent => :destroy
  has_many :enrollments, :dependent => :destroy
  belongs_to :owner, :class_name => "User" , :foreign_key => "user_id"
  belongs_to :school
  belongs_to :simple_category
  has_many :statuses, :as => :statusable
  has_many :students, :through => :enrollments, :source => :user, :conditions => [ "enrollments.role_id = ?", 7 ]
  has_many :teachers, :through => :enrollments, :source => :user, :conditions => [ "enrollments.role_id = ?", 6 ]
  has_many :events, :as => :eventable


  # METODOS DO WIZARD
  attr_writer :current_step

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
    %w[subject course publication]
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



  def create_course_subject_type_course aulas, subject_id, current_user
   
    aulas.each do |aula|
     
      course = current_user.courses.find(aula) #find the course by id
      clone_course = course.clone :except => [:view_count, :created_at, :updated_at]#clone it, methodo 'except' relacionado com o plugin vendor/deep_cloning, sem os atributos[view_count, :created_at, :updated_at]
      
      #### clone o conteúdo da aula #######
      type = course.courseable #a aula, pode ser seminar, page or interactive_class
      
      if type.class.to_s.eql?("InteractiveClass") #INTERACTIVE CLASS
        
        
        clone_type = InteractiveClass.find(type.id).clone :include => :lessons #type.clone :include => :lessons
        clone_type.save
        
        clone_type.lessons.each do |l| # um lesson pode ser 'Page' or 'Seminar', 
        
          #bug
          #clone_lesson = l.lesson.clone # pode ser page or seminar
          #clone_lesson.save 
          #l.lesson_id = clone_lesson.id
          #l.save
          clone_lesson = Lesson.find(l.id)
          clone_lesson.lesson_id = clone_type.id  
          clone_lesson.save
          
        end
        
      elsif type.class.to_s.eql?("Seminar") #SEMINAR
        
        #clone_type = Seminar.find(type.id).clone
        #clone_type.save
        
      else #Page  
        clone_type = type.clone 
        clone_type.save
      end  
      clone_course.courseable_type = clone_type.class.to_s 
      clone_course.courseable_id = clone_type.id
      
      ##### fim do clone do conteúdo da aula######
      clone_course.is_clone = true
      clone_course.save#and save it
      
      ####depois####
      
      ########
      
      cs = CourseSubject.new
      cs.subject_id = subject_id
      cs.courseable_id = clone_course.id
      cs.courseable_type = "Course"
      cs.save
    end

  end


  def update_course_subject_type_course aulas, subject_id, current_user

    aulas_futuras =   aulas.nil? ? Array.new : aulas.map{|a| a.to_i}  #aulas selecionadas na tela, há um operador ternário
    #caso o usuario deschecar todas aulas ou nao houver aula associoda ao curso

    subject = current_user.subjects.find(subject_id) # meu current curso

    aulas_ids = subject.aulas.map{|a| a.id} # aulas relaciondas com o curso
    deleted_ids =  aulas_ids - aulas_futuras # aulas q serao deletadas
    inserted_ids = aulas_futuras - aulas_ids #aulas q serao inseridas

    CourseSubject.destroy_all(:courseable_id => deleted_ids) unless deleted_ids.empty?#segurança ok, pois o array deleted_ids eh criado a partir do current_user

   
    unless inserted_ids.empty?
      inserted_ids.each do |aula|

        course = current_user.courses.find(aula) #find the course by id
        clone_course = course.clone :except => [:view_count, :created_at, :updated_at] #clone it
        #### clone o conteúdo da aula #######
        type = course.courseable #a aula, pode ser seminar, page or interactive_class

        if type.class.to_s.eql?("InteractiveClass") #INTERACTIVE CLASS


          clone_type = InteractiveClass.find(type.id).clone :include => :lessons #type.clone :include => :lessons
          clone_type.save

          clone_type.lessons.each do |l| # um lesson pode ser 'Page' or 'Seminar', 

            #bug
            #clone_lesson = l.lesson.clone # pode ser page or seminar
            #clone_lesson.save 
            #l.lesson_id = clone_lesson.id
            #l.save
            clone_lesson = Lesson.find(l.id)
            clone_lesson.lesson_id = clone_type.id  
            clone_lesson.save

          end

        elsif type.class.to_s.eql?("Seminar") #SEMINAR

          #clone_type = type.clone :include => :lessons
          #clone_type.save
          clone_type = Seminar.find(type.id).clone :include => :lessons 
          clone_type.save

        else #Page  
          clone_type = type.clone 
          clone_type.save
        end  
        clone_course.courseable_type = clone_type.class.to_s 
        clone_course.courseable_id = clone_type.id
        ##### fim do clone do conteúdo da aula######
        clone_course.is_clone = true
        clone_course.save#and save it
        cs = CourseSubject.new
        cs.subject_id = subject_id
        cs.courseable_id = clone_course.id
        cs.courseable_type = "Course"
        cs.save
      end
    end
    
    #######rearrange courses###########
    
    subject = current_user.subjects.find(subject_id) #atualizado
    aulas_ids = subject.aulas.map{|a| a.id} # aulas relaciondas com o curso, atualizado.
    compare = aulas_futuras <=> aulas_ids 
    
    if compare != 0
       
      aulas_futuras.each_with_index do |item, index|
         
        obj = subject.aulas.detect{|a| a.id == item}     
        unless obj.nil?
          #obj.course_subject.position = index
          #obj.save
          aux = Course.find(obj.id).course_subject
          aux.position = index
          aux.save 
        end    
      end  
    
    end
    ######end rearrange###########

   
  end

   

  def update_course_subject_type_exam exams, subject_id, current_user

    exams_futuras =   exams.nil? ? Array.new : exams.map{|a| a.to_i}  #aulas selecionadas na tela, há um operador ternário
    #caso o usuario deschecar todas aulas ou nao houver aula associoda ao curso

    subject = current_user.subjects.find(subject_id) # meu current curso

    exames_ids = subject.exames.map{|a| a.id} # aulas relaciondas com o curso
    deleted_ids =  exames_ids  - exams_futuras # aulas q serao deletadas
    inserted_ids = exams_futuras-  exames_ids #aulas q serao inseridas

    CourseSubject.destroy_all(:courseable_id => deleted_ids) unless deleted_ids.empty?#segurança ok, pois o array deleted_ids eh criado a partir do current_user


    unless inserted_ids.empty?
      inserted_ids.each do |exame_id|

        exame = current_user.exams.find(exame_id) #find the course by id
        clone_exame = exame.clone #clone it
        clone_exame.is_clone = true
        clone_exame.save#and save it
        cs = CourseSubject.new
        cs.subject_id = subject_id
        cs.courseable_id = clone_exame.id
        cs.courseable_type = "Exam"
        cs.save
      end
    end

  end


  def create_course_subject_type_exam exams, subject_id, current_user

    exams.each do |exam_id|
      exame = current_user.exams.find(exam_id) #find exame by id
      clone_exame = exame.clone #clone it
      #### clone o conteúdo do exame #######
=begin      
      type = exame #a aula, pode ser seminar, page or interactive_class
      
      clone_type = type.clone :include => [:lessons]
      clone_type.save
        
        InteractiveClass.find(clone_type.id).lessons.each do |l| # um lesson pode ser 'Page' or 'Seminar', 
          clone_lesson = l.lesson.clone # pode ser page or seminar
          clone_lesson.save 
          l.lesson_id = clone_lesson.id
          l.save
        end
        
        
      clone_course.courseable_type = clone_type.class.to_s 
      clone_course.courseable_id = clone_type.id
=end      
      ##### fim do clone do conteúdo da aula######
      clone_exame.is_clone = true
      clone_exame.save#and save it
      cs = CourseSubject.new
      cs.subject_id = subject_id
      cs.courseable_id = exam_id
      cs.courseable_type = "Exam"
      cs.save
    end

  end

  def aulas
    self.course_subjects.select{|cs| cs.courseable_type.eql?("Course")}.map{|a| a.courseable}
  end

  def exames
    self.course_subjects.select{|cs| cs.courseable_type.eql?("Exam")}.map{|e| e.courseable}
  end

  def students
    self.enrollments.map{|e| e.user}
  end


end
