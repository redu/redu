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
    # A navegação de Environment não possui sidebar, bloco apenas para
    # manter o padrão
    primary.item :sidebar, 'Sidebar', home_path do |tabs|
      tabs.dom_class = 'clearfix ui-tabs-nav'
      tabs.item :infos, 'Informações', edit_environment_path(@environment),
        :highlights_on => action_matcher('environments', ['edit', 'update']),
        :class => 'ui-state-default',
        :link => { :class => "icon-bio_16_18-before" }
      tabs.item :infos, 'Cursos', admin_courses_environment_path(@environment),
        :highlights_on => action_matcher(['environments', 'courses'],
                                         ['admin_courses', 'new', 'create']),
        :class => 'ui-state-default',
        :link => { :class => "icon-course_16_18-before" },
        :details => { :text => 'novo curso', :class => 'details',
          :if => action_matcher('courses', ['new', 'create'])}
      tabs.item :members, 'Membros', admin_members_environment_path(@environment),
        :class => 'ui-state-default',
        :link => { :class => "icon-members_16_18-before" }
    end
  end
end
