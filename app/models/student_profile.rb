class StudentProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject
  belongs_to :course_subject


  def self.create_profile subject_id, current_user
    if current_user.student_profiles.detect{|e| e.subject_id == subject_id.to_i}.nil? #criar apenas um perfil para um curso
      current_user.student_profiles.create(:subject_id => subject_id, :graduaded => 0)
    end
  end

 ##determina em qual aula o aluno está!!
  def to_count course 
    self.course_subject = course.course_subject
    self.save
  end
  
  ##metodo q calcula a percentagem de aula assistida##
  def coursed_percentage subject
    aulas = subject.aulas.map{|a| a.id} #ids todas aulas do curso
    total = aulas.length ##TODO adicionar exames
    index =  self.course_subject_id.nil? ? 0 : aulas.index(CourseSubject.find(self.course_subject_id).courseable.id)+1  #quero obter o indice da aula q aluno cursou ate agora, atraves do course_subject_id
    return  index == 0 ? 0 : ((100*index)/total).to_i
  end


end
