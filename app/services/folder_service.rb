class FolderService

  def initialize(opts)
    @ability = opts.delete(:ability)
    @quota = opts.delete(:quota)
    @attrs = opts
  end

  # Cria Folder com os atributos passados na inicialização garantindo a
  # autorização (:manage).
  #
  # Retorna a instância do MyFfile.
  # Lança CanCan::AccessDenied caso não haja autorização
  def create(&block)
    instance = build(&block)
    authorize!(instance)
    instance.save
    instance
  end

  def build(&block)
    if block
      model.new(attrs, &block)
    else
      model.new(attrs)
    end
  end

  # Destroy Folder e garante a autorização (:manage).
  #
  # Retorna a instância do Folder.
  # Lança CanCan::AccessDenied caso não haja autorização
  def destroy(folder)
    authorize!(folder)
    folder.destroy
    refresh! #só atualiza quotas na destruição
    folder
  end

  protected

  attr_reader :attrs, :quota, :ability

  def model
    Folder
  end

  def authorize!(folder)
    ability.authorize!(:manage, folder)
  end

  def refresh!
    quota.refresh!
  end
end
