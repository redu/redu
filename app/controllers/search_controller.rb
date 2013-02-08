class SearchController < BaseController
  layout "new_application"

  before_filter :authorize

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = perform_results(UserSearch, true)
    @environments = perform_results(EnvironmentSearch, true)
    @courses = perform_results(CourseSearch, true)
    @spaces = perform_results(SpaceSearch, true)

    @total_results = [@profiles.length, @environments.length,
                      @courses.length, @spaces.length].sum

    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
      format.json do
        @all = Array.new
        @all << JSON.parse(make_representable(@profiles).to_json) unless @profiles.empty?
        @all << JSON.parse(make_representable(@environments).to_json) unless @environments.empty?
        @all << JSON.parse(make_representable(@courses).to_json) unless @courses.empty?
        @all << JSON.parse(make_representable(@spaces).to_json) unless @spaces.empty?
        @all.flatten!
        render :json => @all
      end
    end
  end

  # Busca por Perfis
  def profiles
    @profiles = perform_results(UserSearch)
    @total_results = @profiles.length

    respond_to do |format|
      format.html # search/profiles.html.erb
      format.json do
        render :json => make_representable(@profiles)
      end
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  def environments
    @environments = has_filter?("ambientes") ? perform_results(EnvironmentSearch, true) : []
    @courses = has_filter?("cursos") ? perform_results(CourseSearch, true) : []
    @spaces = has_filter?("disciplinas") ? perform_results(SpaceSearch, true) : []

    @total_results = [@environments.length, @courses.length, @spaces.length].sum

    @query = params[:q]

    respond_to do |format|
      format.html # search/environments.html.erb
      format.json do
        @all = []
        @all << JSON.parse(make_representable(@environments).to_json) unless @environments.empty?
        @all << JSON.parse(make_representable(@courses).to_json) unless @courses.empty?
        @all << JSON.parse(make_representable(@spaces).to_json) unless @spaces.empty?
        @all.flatten!
        render :json => @all
      end
    end
  end

  # GET /busca/ambientes?f[]=ambientes
  # Busca por Ambientes (Somente AVA's)
  def environments_only
    @environments = perform_results(EnvironmentSearch)
    @total_results = params[:total_results]

    respond_to do |format|
      format.html # search/environments_only.html.erb
      format.json { render :json => make_representable(@environments) }
    end
  end

  # GET /busca/ambientes?f[]=cursos
  # Busca por Cursos
  def courses_only
    @courses = perform_results(CourseSearch)
    @total_results = params[:total_results]

    respond_to do |format|
      format.html # search/courses_only.html.erb
      format.json { render :json => make_representable(@courses) }
    end
  end

  # GET /busca/ambientes?f[]=disciplinas
  # Busca por Disciplinas
  def spaces_only
    @spaces = perform_results(SpaceSearch)
    @total_results = params[:total_results]

    respond_to do |format|
      format.html # search/spaces_only.html.erb
      format.json { render :json => make_representable(@spaces) }
    end
  end

  private

  def make_representable(collection)
    collection.extend(InstantSearch::CollectionRepresenter)
  end

  def authorize
    authorize! :search, :all
  end

  # Realiza a busca com os params já setados
  def perform_results(klass, preview = false)
    if preview
      per_page = Redu::Application.config.search_preview_results_per_page
    else
      per_page = Redu::Application.config.search_results_per_page
    end

    klass.perform(params[:q], per_page, params[:format],
                  params[:page]).results
  end

  def has_filter?(entity)
    # Se o params[:f] não existir, significa executar
    # a busca em todos os ambientes
    params[:f] ? params[:f].include?(entity) : true
  end
end
