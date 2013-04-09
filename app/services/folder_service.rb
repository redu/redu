class FolderService < StoredContentService
  def initialize(options)
    super options.merge(:model_class => Folder)
  end

  # Destroy Folder e garante a autorização (:manage).
  #
  # Retorna a instância do Folder.
  # Lança CanCan::AccessDenied caso não haja autorização
  def destroy
    authorize!(model)
    model.destroy
    refresh!
    model
  end

  # Atualiza Folder e garante a autorização (:manage).
  #
  # Retorna true caso o modelo tenha sido salvo.
  # Lança CanCan::AccessDenied caso não haja autorização
  def update(attrs)
    authorize!(model)
    model.update_attributes(attrs)
  end

  protected

  def infered_quota
    if model && model.space
      model.space.course.quota || model.space.course.environment.quota
    end
  end

  def authorize!(folder)
    ability.authorize!(:manage, folder)
  end
end
