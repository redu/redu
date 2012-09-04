class NotifySpaceAddedJob
  # Notifica os membros do curso (previamente aprovados) que
  # a disciplina foi criada.
  # - Se a entidade for notifiable
  attr_accessor :space_id

  def initialize(opts)
   @space_id = opts[:space_id]
  end

  def perform
    space = Space.find_by_id(@space_id)
    space.notify_space_added if space
  end
end
