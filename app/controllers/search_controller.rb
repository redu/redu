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
      format.js do
        @all = Array.new
        @all << parse(@profiles)
        @all << parse(@environments)
        @all << parse(@courses)
        @all << parse(@spaces)
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
      format.js do
        render :json => parse(@profiles)
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
      format.js do
        @all = []
        @all << parse(@environments)
        @all << parse(@courses)
        @all << parse(@spaces)
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
      format.js { render :json => parse(@environments) }
    end
  end

  # GET /busca/ambientes?f[]=cursos
  # Busca por Cursos
  def courses_only
    @courses = CourseSearch.perform(params[:q], params[:page], params[:per_page]).results

    respond_to do |format|
      format.html # search/courses_only.html.erb
      format.js { render :json => parse(@courses) }
    end
  end

  # GET /busca/ambientes?f[]=disciplinas
  # Busca por Disciplinas
  def spaces_only
    @spaces = SpaceSearch.perform(params[:q], params[:page], params[:per_page]).results

    respond_to do |format|
      format.html # search/spaces_only.html.erb
      format.js { render :json => parse(@spaces) }
    end
  end

  private

  def parse(collection)
    JSON.parse(collection.extend(InstantSearch::CollectionRepresenter).to_json)
  end
end
