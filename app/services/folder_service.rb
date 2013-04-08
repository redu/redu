class FolderService

  def initialize(opts)
    @attrs = opts
  end

  # Cria Folder com os atributos passados na inicialização
  # Retorna a instância de Folder.
  def create(&block)
    instance = build(&block)
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

  protected

  attr_reader :attrs

  def model
    Folder
  end
end
