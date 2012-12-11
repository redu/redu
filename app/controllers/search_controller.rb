class SearchController < BaseController

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = UserSearch.new(params[:per_page]).perform(params[:q], params[:page]).results
    @environments = EnvironmentSearch.new(params[:per_page]).perform(params[:q], params[:page]).results
    @courses = CourseSearch.new(params[:per_page]).perform(params[:q], params[:page]).results
    @spaces = SpaceSearch.new(params[:per_page]).perform(params[:q], params[:page]).results
    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
      format.js do
        @all = Array.new
        @all << JSON.parse(@profiles.extend(InstantSearch::CollectionRepresenter).to_json)
        @all << JSON.parse(@environments.extend(InstantSearch::CollectionRepresenter).to_json)
        @all << JSON.parse(@courses.extend(InstantSearch::CollectionRepresenter).to_json)
        @all << JSON.parse(@spaces.extend(InstantSearch::CollectionRepresenter).to_json)
        @all = @all.flatten
        render :json => @all
      end
    end
  end

  # Busca por Perfis
  def profiles
    @profiles = UserSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/profiles.html.erb
      format.js { render :json => @profiles.to_json }
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  def environments
    @environments = EnvironmentSearch.new.perform(params[:q], params[:page]).results
    @courses = CourseSearch.new.perform(params[:q], params[:page]).results
    @spaces = SpaceSearch.new.perform(params[:q], params[:page]).results
    @query = params[:q]

    respond_to do |format|
      format.html # search/environments.html.erb
      format.js do
        @all = []
        @all << @environments.to_json
        @all << @courses.to_json
        @all << @spaces.to_json
        @all = @all.flatten
        render :json => @all
      end
    end
  end

  # Busca por Ambientes (Somente AVA's)
  def environments_only
    @environments = EnvironmentSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/environments_only.html.erb
      format.js { render :json => @environments.to_json }
    end
  end

  # Busca por Cursos
  def courses_only
    @courses = CourseSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/courses_only.html.erb
      format.js { render :json => @courses.to_json }
    end
  end

  # Busca por Disciplinas
  def spaces_only
    @spaces = SpaceSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/spaces_only.html.erb
      format.js { render :json => @spaces.to_json }
    end
  end
end
