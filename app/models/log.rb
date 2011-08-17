class Log < Status
  # Atributos:
  #   - logeanle: objecto que foi sujeito a uma determinada acao
  #   - statusable: entidade cujo mural mostrará o log
  # Logs criados automaticamente
  #   - Criação de Courses
  #     logeagle: curso
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

  belongs_to :logeable, :polymorphic => true

  validates_presence_of :action

  attr_protected :text

  def self.setup(model, options={})
    settings = {
      :action => :create,
      :save => true
    }.merge(options)

    log = case model.class.to_s
    when "Course"
      model.logs.new(:action => settings[:action],
                             :user => model.owner,
                             :statusable => model.owner)
    when "UserCourseAssociation"
      if (model.approved? && model.logs.empty?)
        model.logs.new(:action => settings[:action],
                       :user => model.user,
                       :statusable => model.course)
      end
    when "Space"
      model.logs.new(:action => settings[:action],
                             :user => model.owner,
                             :statusable => model.course)
    when "Subject"
      if (model.finalized && model.visible && !model.logs.exists?)
        model.logs.new(:action => settings[:action],
                       :user => model.owner,
                       :statusable => model.space)
      end
    when "Lecture"
      if (model.subject.finalized && model.subject.visible)
        model.logs.new(:action => settings[:action],
                       :user => model.owner,
                       :statusable => model.subject.space)
      end
    when "User"
      model.logs.new(:action => settings[:action],
                             :user => model,
                             :statusable => model)
    when "Experience", "Education"
      model.logs.new(:action => settings[:action],
                             :user => model.user,
                             :statusable => model.user)
    when "Friendship"
      if model.accepted?
        user = model.user
        user.logs.new(:action => settings[:action],
                      :user => model.user,
                      :statusable => model.user)
      end
    else
      nil
    end

    if settings[:save]
      log.try(:save)
    end

    return log
  end
end
