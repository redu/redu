class SearchController < BaseController

  PER_PAGE = Rails.application.config.search_results_per_page

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = results_for(search(User, params[:q], params[:page]))
    @environments = results_for(search(Environment, params[:q], params[:page]))
    @courses = results_for(search(Course, params[:q], params[:page]))
    @spaces = results_for(search(Space, params[:q], params[:page]))
    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
    end
  end

  # Busca por Perfis
  def profiles
    @profiles = results_for(search(User, params[:q], params[:page]))

    respond_to do |format|
      format.html # search/profiles.html.erb
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  def environments
    @environments = results_for(search(Environment, params[:q], params[:page]))
    @courses = results_for(search(Course, params[:q], params[:page]))
    @spaces = results_for(search(Space, params[:q], params[:page]))
    @query = params[:q]

    respond_to do |format|
      format.html # search/environments.html.erb
    end
  end

  # Busca por Ambientes (Somente AVA's)
  def environments_only
    @environments = results_for(search(Environment, params[:q], params[:page]))

    respond_to do |format|
      format.html # search/environments_only.html.erb
    end
  end

  # Busca por Cursos
  def courses_only
    @courses = results_for(search(Course, params[:q], params[:page]))

    respond_to do |format|
      format.html # search/courses_only.html.erb
    end
  end

  # Busca por Disciplinas
  def spaces_only
    @spaces = results_for(search(Space, params[:q], params[:page]))

    respond_to do |format|
      format.html # search/spaces_only.html.erb
    end
  end

  private

  def search(model, query, page)
    Sunspot.search(model) do
      fulltext query
      paginate :page => page, :per_page => PER_PAGE
    end
  end

  def results_for(search)
    search.results
  end
end
