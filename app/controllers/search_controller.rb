class SearchController < BaseController
  layout "new_application"

  before_filter :authorize

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    search_service = SearchService.new(:params => params,
                                       :current_user => current_user)

    search_service.perform_results(:preview => true)

    @profiles = search_service.klass_results("UserSearch")
    @environments = search_service.klass_results("EnvironmentSearch")
    @courses = search_service.klass_results("CourseSearch")
    @spaces = search_service.klass_results("SpaceSearch")

    # Total de resultados
    @total_results = search_service.total_count_results
    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
      format.json do
        render :json => search_service.make_representable
      end
    end
  end

  # Busca por Perfis
  def profiles
    search_service = SearchService.new(:params => params)
    search_service.perform_results

    @profiles = search_service.klass_results("UserSearch")
    @total_results = search_service.total_count_results

    @query = params[:q]

    respond_to do |format|
      format.html # search/profiles.html.erb
      format.json do
        render :json => search_service.make_representable
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
    klasses_results = search_service.perform_results(:preview => preview)

    @environments = search_service.klass_results("EnvironmentSearch")
    @courses = search_service.klass_results("CourseSearch")
    @spaces = search_service.klass_results("SpaceSearch")

    # Total de resultados
    @total_results = search_service.total_count_results

    # Define a entidade que será paginada
    @entity_paginate = search_service.result_paginate

    respond_to do |format|
      format.html # search/environments.html.erb
      format.json do
        render :json => search_service.make_representable
      end
    end
  end

  private

  def authorize
    authorize! :search, :all
  end
end
