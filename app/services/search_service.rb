class SearchService
  # Serviço para busca.
  # Métodos auxiliares que lidam com os parametros da requisição
  # e com a chamada da busca pelos métodos individuais.
  # Desacopla ao máximo a lógica do controller trazendo para esta classe

  def initialize(opts={})
    @params = opts[:params].clone
    @ability = opts[:ability]
    @user = opts[:current_user]
    @filters = params[:f] ? params[:f].clone : {}
    @results = Hash.new
  end

  # Executa busca para as classes definidas pelo usuário
  def perform_results(opts = { :preview => false })
    # Para cada classe executa a busca correspondente
    klasses_for_search.each do |klass|
      per_page = search_per_page(opts[:preview])

      results[klass.to_s] = klass.perform(params[:q], per_page, params[:format],
                                          params[:page]).results

      if klass == SpaceSearch
        page = params[:page].nil? ? 1 : params[:page]
        options = { :page => page, :per_page => per_page }
        results[klass.to_s] =
          filter_and_paginate_my_spaces(results["SpaceSearch"], user, options)
      end
    end

    results
  end

  def total_count_results
    search_results.map{ |entity| entity.total_count }.sum
  end

  # Faz a representação da busca em formato JSON
  def make_representable
    # Para cada tipo de resultado aplica o representer, transforma em JSON
    # e devolve apenas os values do Hash segundo o formato que o tokeninput
    # recebe na view
    all = search_results.map do |collection|
      representer = collection.extend(InstantSearch::CollectionRepresenter)
      itens = JSON.parse(representer.to_json)

      itens.values unless itens.empty?
    end

    # Deixa o array com um apenas um nível, remove os resultados nil
    all = all.flatten!.try(:compact)
    # Ordena para que os profiles sejam os priméiros no resultado
    # [requisito de front-end] Ver #1482
    all.try(:sort){|a, b| b["type"] <=> a["type"]}
  end

  # Recupera resultado referente a uma classe e sempre define um array paginado
  def klass_results(klass)
    results[klass] ||= Kaminari.paginate_array([])
  end

  # Pagina a única busca que possui resultados
  def result_paginate
    if individual_page?
      search_results.select{ |entity| entity.size > 0 }.first || []
    end
  end

  # Se a action receber apenas um filtro é mostrada uma página individual
  def individual_page?
    filters.size == 1 || params[:action] == "profiles"
  end

  # Preview quando não é uma página individual
  def preview?
    !individual_page?
  end

  protected

  attr_reader :params, :user, :ability, :filters, :results

  def search_results
    results.values
  end

  def has_filter?(entity)
    # Se os filtros não existirem está implícito que
    # todos os filtros estão ativados
    filters.include?(entity) || filters.empty?
  end

  # Define para quais classes serão feitas as buscas dependendo dos parametros
  def klasses_for_search
    klasses = Array.new

    # Verifica quais filtros estão ativos e
    # avalia a busca dos modelos correspondentes
    if params[:action] == "environments"
      klasses << EnvironmentSearch if has_filter?("ambientes")
      klasses << CourseSearch if has_filter?("cursos")
      klasses << SpaceSearch if has_filter?("disciplinas")
    elsif params[:action] == "profiles"
      klasses << UserSearch
    else
      klasses = [UserSearch, EnvironmentSearch, CourseSearch, SpaceSearch]
    end

    klasses
  end

  # Define a quantidade de resultados da busca que serão mostrados
  def search_per_page(preview)
    if params[:format] == "json"
      if params[:action] == "profiles"
        Redu::Application.config.instant_search_results_per_page
      else
        Redu::Application.config.instant_search_preview_results_per_page
      end
    elsif preview
      Redu::Application.config.search_preview_results_per_page
    else
      Redu::Application.config.search_results_per_page
    end
  end

  # Filtra somente os spaces que o usuário tem acesso
  # pagina de acordo com os parâmetros recebidos
  def filter_and_paginate_my_spaces(collection, user, options)
    # Filtra os espaços que o usuário tem acesso
    my_spaces = collection.select{ |space| ability.can? :show, space }

    Kaminari.paginate_array(my_spaces).page(options[:page]).
      per_page(options[:per_page])
  end
end
