# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  navigation.selected_class = 'ui-state-active'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  navigation.autogenerate_item_ids = false

  # Define the primary navigation
  navigation.items do |primary|
    primary.dom_class = 'nav-global-buttons'
    primary.selected_class = 'nav-global-button-active'

    primary.item :start, 'Início', home_user_path(current_user), :title => 'Início', :class => 'nav-global-button'
    primary.item :teach, 'Ensine', teach_index_path, :title => 'Ensine', :class => 'nav-global-button'
    primary.item :courses, 'Cursos', courses_index_path, :title => 'Cursos', :class => 'nav-global-button' do |sidebar|
      # A navegação de Environment não possui sidebar, bloco apenas para
      # manter o padrão
      sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
        tabs.dom_class = 'clearfix ui-tabs-nav'
        tabs.item :infos, 'Informações', edit_environment_path(@header_environment || @environment),
          :highlights_on => action_matcher({'environments' => ['edit', 'update']}),
          :class => 'ui-state-default',
          :link => { :class => "icon-bio_16_18-before" }
        tabs.item :infos, 'Cursos', admin_courses_environment_path(@header_environment || @environment),
          :highlights_on => action_matcher({'environments' => ['admin_courses'],
                                           'courses' => ['new', 'create']}),
          :class => 'ui-state-default',
          :link => { :class => "icon-course_16_18-before" },
          :details => { :text => 'novo', :class => 'details',
            :if => action_matcher({'courses' => ['new', 'create']})}
        tabs.item :members, 'Membros', admin_members_environment_path(@header_environment || @environment),
          :highlights_on => action_matcher({'environments' => ['admin_members'],
                                            'roles' => ['show']}),
          :class => 'ui-state-default',
          :link => { :class => "icon-members_16_18-before" },
          :details => { :text => 'papéis', :class => 'details',
            :if => action_matcher({'roles' => ['show']})}
      end
    end
    primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url], :title => 'Aplicativos', :class => 'nav-global-button'
  end
end
