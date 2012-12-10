class SearchController < BaseController

  PER_PAGE = Rails.application.config.search_results_per_page

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    @profiles = search_for_profiles(params[:q], params[:page])
    @environments = search_for_environments(params[:q], params[:page])
    @courses = search_for_courses(params[:q], params[:page])
    @spaces = search_for_spaces(params[:q], params[:page])
    @query = params[:q]

    respond_to do |format|
      format.html # search/index.html.erb
    end
  end

  # Busca por Perfis
  def profiles
    @profiles = search_for_profiles(params[:q], params[:page])

    respond_to do |format|
      format.html # search/profiles.html.erb
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  def environments
    @environments = search_for_environments(params[:q], params[:page])
    @courses = search_for_courses(params[:q], params[:page])
    @spaces = search_for_spaces(params[:q], params[:page])
    @query = params[:q]

    respond_to do |format|
      format.html # search/environments.html.erb
    end
  end

  # Busca por Ambientes (Somente AVA's)
  def environments_only
    @environments = search_for_environments(params[:q], params[:page])

    respond_to do |format|
      format.html # search/environments_only.html.erb
    end
  end

  # Busca por Cursos
  def courses_only
    @courses = search_for_courses(params[:q], params[:page])

    respond_to do |format|
      format.html # search/courses_only.html.erb
    end
  end

  # Busca por Disciplinas
  def spaces_only
    @spaces = search_for_spaces(params[:q], params[:page])

    respond_to do |format|
      format.html # search/spaces_only.html.erb
    end
  end

  private

  def search(model, opts)
    model.send("search", { :include => opts[:include] }) do
      fulltext opts[:query]
      paginate :page => opts[:page], :per_page => PER_PAGE
    end
  end

  def results_for(search)
    search.results
  end

  def search_for_profiles(query, page)
    results_for(search(User, { :query => query, :page => page,
                               :include => [:experiences, :tags, :friends,
                                            { :educations => :educationable }] }))
  end

  def search_for_environments(query, page)
    results_for(search(Environment, { :query => query, :page => page,
                                      :include => [:users, :courses, :tags,
                                                   :administrators] }))
  end

  def search_for_courses(query, page)
    results_for(search(Course, { :query => query, :page => page,
                                 :include => [:users, :audiences, :spaces, :tags,
                                              :environment, :owner, :teachers] }))
  end

  def search_for_spaces(query, page)
    results_for(search(Space, { :query => query, :page => page,
                                :include => [:users, :subjects,
                                             :teachers, :owner, :tags,
                                             { :course => :environment }] }))
  end
end
