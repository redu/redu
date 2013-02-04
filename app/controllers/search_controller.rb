class SearchController < BaseController
  before_filter :authorize

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = perform_results(UserSearch)
    @environments = perform_results(EnvironmentSearch)
    @courses = perform_results(CourseSearch)
    @spaces = perform_results(SpaceSearch)

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
    @environments = perform_results(EnvironmentSearch)
    @courses = perform_results(CourseSearch)
    @spaces = perform_results(SpaceSearch)

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

  def perform_results(klass)
    klass.perform(params[:q], params[:format],
                  params[:page], params[:per_page]).results
  end
end
