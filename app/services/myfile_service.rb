class MyfileService
  attr_reader :ability, :quota

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
    instance = build(&block)
    authorize!(instance)
    instance.save
    refresh!
    instance
  end

  def build(&block)
    if block
      model.new(@attrs, &block)
    else
      model.new(@attrs)
    end
  end

  protected

  def authorize!(myfile)
    ability.authorize!(:upload_file, myfile)
  end

  def refresh!
    quota.refresh!
  end

  def model
    Myfile
  end
end
