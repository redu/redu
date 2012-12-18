class Search
  #
  # A classe Search abstrai a lógica de execução de buscas do Sunspot, possibilitando
  # que suas herdeiras (UserSearch e EnvironmentSearch, por exemplo) concretizem
  # a implementação da busca de acordo com o(s) modelo(s) associado(s) a ela.
  #

  attr_reader :klass

  def initialize(model)
    @klass = model
  end

  def search(opts)
    klass.send("search", { :include => opts[:include] }) do
      fulltext opts[:query]
      paginate :page => opts[:page], :per_page => opts[:per_page]
    end
  end
end
