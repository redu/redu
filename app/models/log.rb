# -*- encoding : utf-8 -*-
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
end
