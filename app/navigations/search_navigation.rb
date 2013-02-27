module SearchNavigation
  def search_navigation(sidebar)
    # A navegação de Search não possui sidebar, bloco apenas para manter o padrão
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      tabs.dom_class = 'tabs tabs-big'
      tabs.selected_class = 'tab-active'

      tabs.item :general, 'Geral', search_path(:q => @query),
        :class => 'tab',
        :link => { :class => 'tab-title icon-basic-guide-lightblue_16_18-before',
                   :title => 'Geral'}
      tabs.item :environments, 'Ambientes',
        search_environments_path(:q => @query),
        :class => 'tab',
        :link => { :class => 'tab-title icon-environment-lightblue_16_18-before',
                   :title => 'Ambientes'}
      tabs.item :profiles, 'Perfil', search_profiles_path(:q => @query),
        :highlights_on => %r(\A#{ search_profiles_path }),
        :class => 'tab',
        :link => { :class => 'tab-title icon-profile-lightblue_16_18-before',
                   :title => 'Perfil'}
    end
  end
end
