class Log < Status
  # Atributos:
  #   - logeable: objecto que foi sujeito a uma determinada acao
  #   - statusable: entidade cujo mural mostrará o log
  # Logs criados automaticamente
  #   - Criação de Courses
  #     logeable: curso
  #     statusable: dono do curso (Environment não tem statuses)
  #   - Criaçao de UserCourseAssociation
  #     condição: somente se estiver approved
  #     logeable: UserCourseAssociation
  #     statusable: course
  #   - Criação de Spaces
  #     logeable: space
  #     statusable: course
  #   - Criação Subject (com pelo menos uma aula)
  #     condição: se estiver finalizes e visible
  #     logeable: subject
  #     statusable: space
  #   - Criação de Aulas (sem ser na primeira vez)
  #   - Atualização de User
  #   - Criação de Friendship

  CONFIG = Redu::Application.config.overview_logger

  after_create :check_if_should_compound

  belongs_to :logeable, :polymorphic => true
  belongs_to :compound_log

  validates_presence_of :action

  # Faz setup do Log e salva (a não ser quer :save => false). É assumido
  # que o model é uma instância válida (com relacionamentos, e etc).
  def self.setup(model, options={})
    settings = {
      :action => :create,
      :save => true,
      :text => ''
    }.merge(options)

    log = case model.class.to_s
          when "Course"
            model.logs.new(:action => settings[:action],
                           :user => model.owner,
                           :statusable => model.owner,
                           :text => settings[:text])
          when "UserCourseAssociation"
            if model.notificable?
              model.logs.new(:action => settings[:action],
                             :user => model.user,
                             :statusable => model.course,
                             :text => settings[:text])
            end
          when "Space"
            model.logs.new(:action => settings[:action],
                           :user => model.owner,
                           :statusable => model.course,
                           :text => settings[:text])
          when "Subject"
            if model.notificable?
              model.logs.new(:action => settings[:action],
                             :user => model.owner,
                             :statusable => model.space,
                             :text => settings[:text])
            end
          when "Lecture"
            if model.notificable?
              model.logs.new(:action => settings[:action],
                             :user => model.owner,
                             :statusable => model.subject.space,
                             :text => settings[:text])
            end
          when "User"
            if changed_relevant_attrs?(model)
              model.logs.new(:action => settings[:action],
                             :user => model,
                             :statusable => model,
                             :text => settings[:text])
            end
          when "Experience", "Education"
            model.logs.new(:action => settings[:action],
                           :user => model.user,
                           :statusable => model.user,
                           :text => settings[:text])
          when "Friendship"
            if model.notificable?
              model.logs.new(:action => settings[:action],
                             :user => model.user,
                             :statusable => model.user,
                             :text => settings[:text])
            end
    else
      nil
    end

    if settings[:save]
      log.try(:save)
    end

    return log
  end

  # Consulta o logs.yml e carrega a mensagem apropriada
  def action_text
    msgs = CONFIG[logeable_type.parameterize].try(:fetch, 'messages')
    msgs ||= {}
    msgs.fetch(action.to_s, "")
  end

  protected

  # Verifica se o atributo especificado nas configs foi atualizado
  def self.changed_relevant_attrs?(model)
    !(model.changed & tracked_attrs(model)).empty?
  end

  # Atributos relevantes para o log. Se não foi especificado nas configs. retorna
  # todos os atributos
  def self.tracked_attrs(model)
    config = CONFIG[model.class.to_s.parameterize]
    config ||= {}

    config.fetch('attrs', model.attribute_names)
  end

  # Checa se deve compor o log
  def check_if_should_compound
    compound_log = CompoundLog.find_by_statusable_id(self.statusable_id)
    if compound_log
      # Já existe log composto: verifica se deve habilitá-lo
      if compound_log.logs.count == 4
        compound_log.logs << self
        compound_log.compound = false # Exibe status na view
        new_compound = CompoundLog.new(:statusable_type => self.statusable_type,
                                       :statusable_id => self.statusable_id,
                                       :compound => true) # Não exibe status na view  
      end
    else
      # Não existe log composto: cria e associa novo log
      compound_log = CompoundLog.new(:statusable_type => self.statusable_type,
                                     :statusable_id => self.statusable_id,
                                     :compound => true) # Não exibe status na view
      compound_log.logs << self
      self.compound = false # Exibe status na view
    end
  end
end
