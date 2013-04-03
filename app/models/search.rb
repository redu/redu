class Search
  #
  # A classe Search abstrai a lógica de execução de buscas do Sunspot, possibilitando
  # que suas herdeiras (UserSearch e EnvironmentSearch, por exemplo) concretizem
  # a implementação da busca de acordo com o(s) modelo(s) associado(s) a ela.
  #

  def initialize(model)
    @klass = model
  end

  def search(opts)
    opts[:include] ||= []

    klass.send("search", { :include => opts[:include] }) do
      fulltext opts[:query] do
        fields opts[:fields] if opts[:fields]
      end
      order_by :score, opts[:order]
      paginate :page => opts[:page], :per_page => opts[:per_page]
    end
  end

  protected

  attr_reader :klass
end
