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
    primary.item :sidebar, 'Sidebar', home_path do |tabs|
      tabs.dom_class = 'clearfix ui-tabs-nav'
      tabs.item :infos, 'Informações',
        edit_environment_course_path(@environment, @course),
        :highlights_on => action_matcher('courses', ['edit', 'update']),
        :class => 'ui-state-default',
        :link => { :class => "icon-bio_16_18-before" }
      tabs.item :spaces, 'Disciplinas',
        admin_spaces_environment_course_path(@environment, @course),
        :highlights_on => action_matcher(['courses', 'spaces'],
                                         ['admin_spaces', 'new', 'create']),
        :class => 'ui-state-default',
        :link => { :class => "icon-space_16_18-before" },
        :details => { :text => 'nova disciplina',
                      :class => 'details ',
                      :if => action_matcher('spaces', ['new', 'create'])}
      tabs.item :members, 'Membros',
        admin_members_environment_course_path(@environment, @course),
        :class => 'ui-state-default',
        :link => { :class => "icon-members_16_18-before" } do |subtabs|
          subtabs.dom_class = 'clearfix ui-tabs-nav'
          subtabs.item :admin_members, "Lista",
            admin_members_environment_course_path(@environment, @course),
            :class => 'ui-state-default',
            :link => { :class => 'icon-list_16_18-before' }
          subtabs.item :invite_members, "Convites",
            invite_members_environment_course_path(@environment, @course),
            :class => 'ui-state-default',
            :link => { :class => 'icon-add-contact_16_18-before' }
          subtabs.item :moderate_members, "Moderação",
            admin_members_requests_environment_course_path(@environment, @course),
            :class => 'ui-state-default',
            :link => { :class => 'icon-moderation_16_18-before' }
        end
    end
  end
end

