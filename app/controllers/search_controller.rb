class SearchController < BaseController

  rescue_from CanCan::AccessDenied, :with => :deny_access

  PER_PAGE = Rails.application.config.search_results_per_page

  # Busca por Perfis + Ambientes (AVA's, Cursos e Disciplinas)
  def index
    authorize! :index, :search
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
    authorize! :profiles, :search
    @profiles = search_for_profiles(params[:q], params[:page])

    respond_to do |format|
      format.html # search/profiles.html.erb
    end
  end

  # Busca por Ambientes (AVA's, Cursos e Disciplinas)
  def environments
    authorize! :environments, :search
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
    authorize! :environments_only, :search
    @environments = search_for_environments(params[:q], params[:page])

    respond_to do |format|
      format.html # search/environments_only.html.erb
    end
  end

  # Busca por Cursos
  def courses_only
    authorize! :courses_only, :search
    @courses = search_for_courses(params[:q], params[:page])

    respond_to do |format|
      format.html # search/courses_only.html.erb
    end
  end

  # Busca por Disciplinas
  def spaces_only
    authorize! :spaces_only, :search
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
                               :include => [:experiences, :tags,
                                            { :educations  => :educationable }] }))
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

  protected

  def deny_access(exception)
    session[:return_to] = request.fullpath
    if exception.action == :preview && exception.subject.class == Space
      flash[:notice] = "Essa área só pode ser vista após você acessar o Redu com seu nome e senha."
      redirect_to preview_environment_course_path(@space.course.environment,
                                                  @space.course)
    else
      super
    end
  end
end
