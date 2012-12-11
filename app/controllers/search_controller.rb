class SearchController < BaseController

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = UserSearch.new.perform(params[:q], params[:page]).results
    @environments = EnvironmentSearch.new.perform(params[:q], params[:page]).results
    @courses = CourseSearch.new.perform(params[:q], params[:page]).results
    @spaces = SpaceSearch.new.perform(params[:q], params[:page]).results
    @query = params[:q]

    if request.xhr?
      @all = []
      if must_include(User, params)
        @all << @profiles.first(5).map do |e|
          { :id => e.id, :name => e.display_name }
        end
      end
      @all << crop(@environments) if must_include(Environment, params)
      @all << crop(@courses) if must_include(Course, params)
      @all << crop(@spaces) if must_include(Space, params)
      @all = @all.flatten
    end

    respond_to do |format|
      format.html # search/index.html.erb
      format.js { render :json => @all }
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

  private

  def crop(collection)
    collection.first(5).map do |e|
      { :id => e.id, :name => e.name }
    end
  end

  def must_include(klass, params)
    !params[:f] || params[:f].include?(klass.to_s)
  end
end
