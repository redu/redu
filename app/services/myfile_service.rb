class MyfileService
  attr_reader :ability

  def initialize(options)
    @ability = options.delete(:ability)
    @quota = options.delete(:quota)
    @attrs = options
  end

  # Cria MyFile com os atributos passados na inicialização garantindo a
  # autorização (:upload_file) e que as quotas são atualizadas.
  #
  # Retorna a instância do MyFfile.
  # Lança CanCan::AccessDenied caso não haja autorização
  def create(&block)
    @model = build(&block)
    authorize!(@model)
    @model.save
    refresh!
    @model
  end

  def build(&block)
    if block
      model_class.new(@attrs, &block)
    else
      model_class.new(@attrs)
    end
  end

  # Retorna quota. Caso não tenha sido passada na inicialização tenta inferir
  # a partir do objeto criado pelo serviço.
  def quota
    @quota ||= infered_quota
  end

  protected

  def infered_quota
    if @model && @model.folder
      @model.folder.space.course.quota || @model.folder.space.course.environment.quota
    end
  end

  def authorize!(myfile)
    ability.authorize!(:upload_file, myfile)
  end

  def refresh!
    quota.refresh!
  end

  def model_class
    Myfile
  end
end
