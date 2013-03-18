class SearchController < BaseController
  layout "new_application"

  before_filter :authorize

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    search_service = SearchService.new(:params => params,
                                       :current_user => current_user)

    klasses_results = search_service.perform_klasses_results(:preview => true)

    @profiles = klasses_results["UserSearch"]
    @environments = klasses_results["EnvironmentSearch"]
    @courses = klasses_results["CourseSearch"]
    @spaces = klasses_results["SpaceSearch"]

    results = [@profiles, @environments, @courses, @spaces]
    @total_results = results.map{ |entity| entity.total_count }.sum

    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
      format.json do
        render :json => SearchService.new(:params => params).make_representable(results)
      end
    end
  end

  # Busca por Perfis
  def profiles
    search_service = SearchService.new(:params => params)

    @profiles = search_service.perform_results(UserSearch)
    @total_results = @profiles.total_count

    @query = params[:q]

    respond_to do |format|
      format.html # search/profiles.html.erb
      format.json do
        render :json => SearchService.new(:params => params).make_representable([@profiles])
      end
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  # Esta action recebe filtros para mostrar resultados desejados
  def environments
    search_service = SearchService.new(:params => params,
                                       :current_user => current_user)
    @query = params[:q]

    @individual_page = search_service.individual_page?
    preview = search_service.preview?

    klasses_results = search_service.perform_klasses_results(:preview => preview)

    @environments = klasses_results["EnvironmentSearch"] ||=
      Kaminari.paginate_array([])
    @courses = klasses_results["CourseSearch"] ||= Kaminari.paginate_array([])
    @spaces = klasses_results["SpaceSearch"] ||= Kaminari.paginate_array([])

    # Array com os resultados
    results = [@environments, @courses, @spaces]
    @total_results = results.map{ |entity| entity.total_count }.sum

    # Se página é individual é definida a entidade que será paginada
    # Este método não é feito antes pois precisa que a busca
    # já tenha sido avaliada.
    if @individual_page
      @entity_paginate = results.select{ |entity| entity.size > 0 }.first || []
    end

    respond_to do |format|
      format.html # search/environments.html.erb
      format.json do
        render :json => SearchService.new(:params => params).make_representable(results)
      end
    end
  end

  private

  def authorize
    authorize! :search, :all
  end
end
