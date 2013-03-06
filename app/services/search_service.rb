class SearchService
  attr_reader :params, :user

  def initialize(opts={})
    @params = opts[:params].clone
    @user = opts[:current_user]
  end

  def perform_klasses_results(klasses, opts)
    results = Hash.new

    klasses.each do |klass|
      if klass == SpaceSearch
        results[klass.to_s] = perform_results(klass, :preview => opts[:preview],
                                              :space_search => true)
      else
        results[klass.to_s] = perform_results(klass, :preview => opts[:preview])
      end
    end

    results
  end

  # Realiza a busca com os params já setados
  def perform_results(klass, opts = { :preview => false,
                                      :space_search => false })
    if opts[:preview]
      per_page = Redu::Application.config.search_preview_results_per_page
    else
      per_page = Redu::Application.config.search_results_per_page
    end

    results = klass.perform(@params[:q], per_page, @params[:format],
                            @params[:page]).results

    if opts[:space_search]
      page = @params[:page].nil? ? 1 : @params[:page]
      options = { :page => page, :per_page => per_page }
      results = filter_and_paginate_my_spaces(results, @user, options)
    end

    results
  end

  # Faz a representação da busca em formato JSON
  # Recebe uma coleção de tipos de resultados
  def make_representable(collections)
    all = Array.new

    # Para cada tipo de resultado aplica o representer, transforma em JSON
    # e devolve apenas os values do Hash segundo o formato que o tokeninput recebe na view
    collections.each do |collection|
      unless collection.empty?
        representer = collection.extend(InstantSearch::CollectionRepresenter)
        itens = JSON.parse(representer.to_json)

        all << itens.values
      end
    end

    all.flatten!
  end

  # Filtra somente os spaces que o usuário tem acesso
  # pagina de acordo com os parâmetros recebidos
  def filter_and_paginate_my_spaces(collection, user, params)
    # Filtra os espaços que o usuário tem acesso
    my_spaces = collection.select{ |space| user.has_access_to?(space) }

    Kaminari.paginate_array(my_spaces).page(params[:page]).
      per(params[:per_page])
  end
end
