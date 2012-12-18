class SearchController < BaseController

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = UserSearch.perform(params[:q], params[:page], params[:per_page]).results
    @environments = EnvironmentSearch.perform(params[:q], params[:page], params[:per_page]).results
    @courses = CourseSearch.perform(params[:q], params[:page], params[:per_page]).results
    @spaces = SpaceSearch.perform(params[:q], params[:page], params[:per_page]).results
    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
      format.json do
        @all = Array.new
        @all << JSON.parse(make_representable(@profiles).to_json) unless @profiles.empty?
        @all << JSON.parse(make_representable(@environments).to_json) unless @environments.empty?
        @all << JSON.parse(make_representable(@courses).to_json) unless @courses.empty?
        @all << JSON.parse(make_representable(@spaces).to_json) unless @spaces.empty?
        @all = @all.flatten
        render :json => @all
      end
    end
  end

  # Busca por Perfis
  def profiles
    @profiles = UserSearch.perform(params[:q], params[:page], params[:per_page]).results

    respond_to do |format|
      format.html # search/profiles.html.erb
      format.json do
        render :json => make_representable(@profiles)
      end
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  def environments
    @environments = EnvironmentSearch.perform(params[:q], params[:page], params[:per_page]).results
    @courses = CourseSearch.perform(params[:q], params[:page], params[:per_page]).results
    @spaces = SpaceSearch.perform(params[:q], params[:page], params[:per_page]).results
    @query = params[:q]

    respond_to do |format|
      format.html # search/environments.html.erb
      format.json do
        @all = []
        @all << JSON.parse(make_representable(@environments).to_json) unless @environments.empty?
        @all << JSON.parse(make_representable(@courses).to_json) unless @courses.empty?
        @all << JSON.parse(make_representable(@spaces).to_json) unless @spaces.empty?
        @all = @all.flatten
        render :json => @all
      end
    end
  end

  # GET /busca/ambientes?f[]=ambientes
  # Busca por Ambientes (Somente AVA's)
  def environments_only
    @environments = EnvironmentSearch.perform(params[:q], params[:page], params[:per_page]).results

    respond_to do |format|
      format.html # search/environments_only.html.erb
      format.json { render :json => make_representable(@environments) }
    end
  end

  # GET /busca/ambientes?f[]=cursos
  # Busca por Cursos
  def courses_only
    @courses = CourseSearch.perform(params[:q], params[:page], params[:per_page]).results

    respond_to do |format|
      format.html # search/courses_only.html.erb
      format.json { render :json => make_representable(@courses) }
    end
  end

  # GET /busca/ambientes?f[]=disciplinas
  # Busca por Disciplinas
  def spaces_only
    @spaces = SpaceSearch.perform(params[:q], params[:page], params[:per_page]).results

    respond_to do |format|
      format.html # search/spaces_only.html.erb
      format.json { render :json => make_representable(@spaces) }
    end
  end

  private

  def make_representable(collection)
    collection.extend(InstantSearch::CollectionRepresenter)
  end
end
