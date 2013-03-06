# Serviço que manipula os parametros que representam os filtros
class SearchParamsService
  attr_reader :filters

  def initialize(params)
    @params = params.clone
    @filters = params[:f] ? params[:f].clone : {}
  end

  # Se a action receber apenas um filtro é mostrada uma página individual
  def individual_page?
    @filters.size == 1
  end

  def preview?
    !individual_page?
  end

  def has_filter?(entity)
    # Se os filtros não existirem está implícito que
    # todos os filtros estão ativados
    @filters.include?(entity) || @filters.empty?
  end

  # Define para quais classes serão feitas as buscas dependendo dos parametros
  def klasses_for_search
    klasses = Array.new

    # Verifica quais filtros estão ativos e
    # avalia a busca dos modelos correspondentes
    if @params[:action] == "environments"
      klasses << EnvironmentSearch if has_filter?("ambientes")
      klasses << CourseSearch if has_filter?("cursos")
      klasses << SpaceSearch if has_filter?("disciplinas")
    elsif @params[:action] == "profiles"
      klasses << UserSearch
    else
      klasses = [UserSearch, EnvironmentSearch, CourseSearch, SpaceSearch]
    end

    klasses
  end
end
