module NavigationHelper
  include UsersNavigation
  include UserProfileNavigation
  include EnvironmentsAdminNavigation
  include EnvironmentsNavigation
  include CoursesIndexNavigation
  include CoursesAdminNavigation
  include CoursesNavigation
  include SpacesAdminNavigation
  include SpacesNavigation
  include PartnersNavigation
  include NewUsersNavigation

  # Renderiza navegação global
  def render_dynamic_navigation(opts = { :level => 1, :renderer => :list })
    # method é o nome do contexto mais "_navigation" always
    method = opts[:context].to_s + "_navigation"

    render_navigation(:level => opts[:level], :renderer => opts[:renderer],
                      :expand_all => opts[:expand_all]) do |primary|
      primary.dom_class = 'nav-global-buttons'
      primary.selected_class = 'nav-global-button-active'

      # Os itens ficam ativados de acordo com a função global_highlights
      # Os métodos são renderizados de acordo com seu contexto
      primary.item :start, 'Início', home_user_path(current_user),
        :title => 'Início', :class => 'nav-global-button',
        :highlights_on => lambda{ global_highlighted == :start } do |sidebar|
          eval_context(method, :start, sidebar)
        end
      primary.item :teach, 'Ensine', teach_index_path,
        :title => 'Ensine', :class => 'nav-global-button'
      primary.item :courses, 'Cursos', courses_index_path,
        :title => 'Cursos', :class => 'nav-global-button',
        :highlights_on => lambda{ global_highlighted == :courses } do |sidebar|
          eval_context(method, :courses, sidebar)
        end
      primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url],
        :title => 'Aplicativos', :class => 'nav-global-button'
    end
  end

  # Executa navegação dentro do seu contexto
  # navigation_method => arquivo da navegação que será renderizado
  # context => item primário que está sendo avaliado
  # sidebar => parametro do item primario para continuação da navegação
  def eval_context(navigation_method, context, sidebar)
    # Avalia se a navegação é do Início
    start_evaluation = (navigation_method.include?("user") ||
                        navigation_method.include?("partner"))

    # Avalia se a navegação é do Curso, se não for do Início e nem global apenas
    course_evaluation = !(start_evaluation || (navigation_method.include? "global"))

    if context == :start
      method(navigation_method).call(sidebar) if start_evaluation
    elsif context == :courses
      method(navigation_method).call(sidebar) if course_evaluation
    end
  end

  # Define item ativo na navegação global, se a url não usar o sidebar
  # de pessoas, aciona o highlights para Cursos
  def global_highlighted
    # Início só é selecionado se estiver realacionado ao current user
    if !request.fullpath.match(%r(\A#{ users_path }/#{ current_user.login })).nil?
      :start
    # Não aciona a navegacão global se estiver na área relacionada a partners
    # ou ao profile de outro usuário
    elsif !request.fullpath.match(%r(\A#{ partners_path })).nil? ||
          !request.fullpath.match(%r(\A#{ users_path }/)).nil?
      :global
    else
      :courses
    end
  end
end
