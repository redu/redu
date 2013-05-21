# -*- encoding : utf-8 -*-
module SearchNavigation
  def search_navigation(sidebar)
    # A navegação de Search não possui sidebar, bloco apenas para manter o padrão
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      tabs.dom_class = 'tabs tabs-big'
      tabs.selected_class = 'tab-active'

      tabs.item :general, 'Geral', search_path(:q => @query), :class => 'tab',
        :highlights_on => action_matcher({ 'search' => ['index'] }),
        :link => { :class => 'tab-title icon-basic-guide-lightblue_16_18-before',
                   :title => 'Geral'}
      tabs.item :environments, 'Ambientes', search_environments_path(:q => @query),
        :highlights_on => action_matcher({ 'search' => ['environments'] }),
        :class => 'tab',
        :link => { :class => 'tab-title icon-environment-lightblue_16_18-before',
                   :title => 'Ambientes'} do |subtabs|
          subtabs.dom_class = 'filters'
          subtabs.selected_class = 'filter-active'

          subtabs.item :environments, 'Ambientes', search_environments_with_params("ambientes"),
            :class => 'filter icon-environment-lightblue_16_18-before',
            :highlights_on => lambda{ search_environments_highlights?("ambientes") }
          subtabs.item :courses, 'Cursos', search_environments_with_params("cursos"),
            :class => 'filter icon-course-lightblue_16_18-before',
            :highlights_on => lambda{ search_environments_highlights?("cursos") }
          subtabs.item :spaces, 'Disciplinas', search_environments_with_params("disciplinas"),
            :class => 'filter icon-space-lightblue_16_18-before',
            :highlights_on => lambda{ search_environments_highlights?("disciplinas") }
        end
      tabs.item :profiles, 'Perfil', search_profiles_path(:q => @query),
        :highlights_on => action_matcher({ 'search' => ['profiles'] }), :class => 'tab',
        :link => { :class => 'tab-title icon-profile-lightblue_16_18-before',
                   :title => 'Perfil'}
    end
  end

  # Define se subtabs ficará ativa
  def search_environments_highlights?(filter)
    # Se "f" não estiver definido, aciona nenhum os filtros
    params[:f].try(:include?, filter)
  end

  # Define quais serão os filtros do path das subtabs
  def search_environments_with_params(filter)
    # Clona objeto para que não haja inconsistência
    filters = params[:f].try(:clone)
    filters ||= []

    if filters.include?(filter)
      # Se o filtro desejado já está selecionado, o mesmo é removido
      filters.delete(filter)
    else
      filters << filter
    end

    search_environments_path(:f => filters, :q => @query)
  end
end
