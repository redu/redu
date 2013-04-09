class MyfileService < StoredContentService
  def initialize(options)
    super options.merge(:model_class => Myfile)
  end

  # Cria MyFile com os atributos passados na inicialização garantindo a
  # autorização (:upload_file) e que as quotas são atualizadas.
  #
  # Retorna a instância do MyFfile.
  # Lança CanCan::AccessDenied caso não haja autorização
  def create(&block)
    refresh! { super }
    model
  end

  protected

  def infered_quota
    if model && model.folder
      model.folder.space.course.quota || model.folder.space.course.environment.quota
    end
  end

  def authorize!(myfile)
    ability.authorize!(:upload_file, myfile)
  end
end
