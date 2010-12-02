class StudentProfile < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject
  belongs_to :asset

  validates_uniqueness_of :user_id, :scope => :subject_id

  def to_count lecture
    self.asset = lecture.asset
    self.save
  end

  # Metodo q calcula a percentagem de aula assistida
  def coursed_percentage subject
    aulas = subject.aulas.map{|a| a.id} #ids todas aulas do curso
    total = aulas.length ##TODO adicionar exames
    #TODO Ajeitar linha abaixo
    index =  self.asset.nil? ? 0 : aulas.index(Asset.find(self.course_subject_id).courseable.id)+1  #quero obter o indice da aula q aluno cursou ate agora, atraves do course_subject_id
    return  index == 0 ? 0 : ((100*index)/total).to_i
  end


end
