class SearchController < BaseController

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = UserSearch.new.perform(params[:q], params[:page]).results
    @environments = EnvironmentSearch.new.perform(params[:q], params[:page]).results
    @courses = CourseSearch.new.perform(params[:q], params[:page]).results
    @spaces = SpaceSearch.new.perform(params[:q], params[:page]).results
    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
    end
  end

  # Busca por Perfis
  def profiles
    @profiles = UserSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/profiles.html.erb
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
    end
  end

  # Busca por Ambientes (Somente AVA's)
  def environments_only
    @environments = EnvironmentSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/environments_only.html.erb
    end
  end

  # Busca por Cursos
  def courses_only
    @courses = CourseSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/courses_only.html.erb
    end
  end

  # Busca por Disciplinas
  def spaces_only
    @spaces = SpaceSearch.new.perform(params[:q], params[:page]).results

    respond_to do |format|
      format.html # search/spaces_only.html.erb
    end
  end
end
