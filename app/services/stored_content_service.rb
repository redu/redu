class StoredContentService
  # Responsável pela manipulação de entidades que atualizam as Quota do AVA.
  attr_reader :ability

  def initialize(opts)
    @ability = opts.delete(:ability)
    @quota = opts.delete(:quota)
    @model_class = opts.delete(:model_class)
    @model = opts.delete(:model)
    @attrs = opts
  end

  def build(&block)
    if block
      model_class.new(attrs, &block)
    else
      model_class.new(attrs)
    end
  end

  # Cria entidade com os atributos passados na inicialização garantindo a
  # autorização.
  #
  # Retorna a instância da entidade.
  # Lança CanCan::AccessDenied caso não haja autorização
  def create(&block)
    @model = build(&block)
    authorize!(model)
    model.save
    model
  end

  # Destroi entidade e garante a autorização.
  #
  # Retorna a instância do Folder.
  # Lança CanCan::AccessDenied caso não haja autorização
  def destroy
    authorize!(model)
    model.destroy
    refresh!
    model
  end

  # Retorna quota. Caso não tenha sido passada na inicialização tenta inferir
  # a partir do objeto criado pelo serviço.
  def quota
    @quota ||= infered_quota
  end

  protected

  def refresh!(&block)
    yield if block_given?
    quota.refresh!
  end

  attr_reader :attrs, :model, :model_class
end

