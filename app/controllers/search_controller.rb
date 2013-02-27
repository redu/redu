class SearchController < BaseController
  layout "new_application"

  before_filter :authorize

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = perform_results(UserSearch, :preview => true)
    @environments = perform_results(EnvironmentSearch, :preview => true)
    @courses = perform_results(CourseSearch, :preview => true)
    @spaces = perform_results(SpaceSearch, :preview => true,
                              :space_search => true)

    @total_results = [@profiles.total_count, @environments.total_count,
                      @courses.total_count, @spaces.total_count].sum

    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
      format.json do
        @all = make_representable([@profiles, @environments, @courses, @spaces])
        render :json => @all
      end
    end
  end

  # Busca por Perfis
  def profiles
    @profiles = perform_results(UserSearch)
    @total_results = @profiles.total_count
    @query = params[:q]

    respond_to do |format|
      format.html # search/profiles.html.erb
      format.json do
        render :json => make_representable([@profiles])
      end
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  # Esta action recebe filtros para mostrar resultados desejados
  #
  # Se a action receber apenas um filtro o resultado é mostrado em
  # uma página individual, com paginação e a quantidade por página diferentes
  def environments
    # Cria arrays com o Kaminari
    @environments = Kaminari.paginate_array([])
    @courses = Kaminari.paginate_array([])
    @spaces = Kaminari.paginate_array([])

    # Atributos defaults para páginnas que não são individuais
    # Define filters a partir do params[:f], preview setado para true,
    # e página indiviual é false
    filters = params[:f] ? params[:f] : {}
    preview = true
    @individual_page = false

    # Se existe apenas um filtro, a página é individual
    if filters.size == 1
      preview = false
      @individual_page = true
    end

    # Verifica quais filtros estão ativos e realia a busca dos modelos correspondentes
    if has_filter?("ambientes")
      @environments = perform_results(EnvironmentSearch, :preview => preview)
    end
    if has_filter?("cursos")
      @courses = perform_results(CourseSearch, :preview => preview)
    end
    if has_filter?("disciplinas")
      @spaces = perform_results(SpaceSearch, :preview => preview,
                                :space_search => true)
    end

    # Array com os resultados
    results = [@environments, @courses, @spaces]

    # Se página é individual é definida a entidade que será paginada
    # Este método não é feito antes pois precisa que a busca já tenha sido avaliada.
    if !preview
      @entity_paginate = results.select{ |entity| entity.size > 1 }.first
    end

    @total_results = results.map{ |entity| entity.total_count }.sum
    @query = params[:q]

    respond_to do |format|
      format.html # search/environments.html.erb
      format.json do
        @all = make_representable(results)
        render :json => @all
      end
    end
  end

  private

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

  def authorize
    authorize! :search, :all
  end

  # Realiza a busca com os params já setados
  def perform_results(klass, opts = { :preview => false,
                                      :space_search => false })
    if opts[:preview]
      per_page = Redu::Application.config.search_preview_results_per_page
    else
      per_page = Redu::Application.config.search_results_per_page
    end

    results = klass.perform(params[:q], per_page, params[:format],
                            params[:page]).results

    if opts[:space_search]
      page = params[:page].nil? ? 1 : params[:page]
      options =  { :page => page, :per_page => per_page }
      results = SpaceSearch.
        filter_and_paginate_my_spaces(results, current_user, options)
    end

    results
  end

  def has_filter?(entity)
    # Se o params[:f] não existir, significa executar
    # a busca em todos os ambientes
    params[:f] ? params[:f].include?(entity) : true
  end
end
