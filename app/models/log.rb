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
            if (model.approved? && model.logs.empty?)
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
            if (model.finalized && model.visible && !model.logs.exists?)
              model.logs.new(:action => settings[:action],
                             :user => model.owner,
                             :statusable => model.space,
                             :text => settings[:text])
            end
          when "Lecture"
            if (model.subject.finalized && model.subject.visible)
              model.logs.new(:action => settings[:action],
                             :user => model.owner,
                             :statusable => model.subject.space,
                             :text => settings[:text])
            end
          when "User"
            unless (model.changed & User::LOGEABLE_ATTRS).empty?
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
            if model.accepted?
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
end
