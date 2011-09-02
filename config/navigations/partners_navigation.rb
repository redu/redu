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
    primary.dom_class = 'clearfix ui-tabs-nav'
    # Aba inexistente no layout, criada apenas para seguir o padrão
    primary.item :primary, 'Primary', partner_path(@partner),
      :highlights_on => Proc.new { action_matcher(['partners', 'partner_environment_associations'], ['show', 'index']).call ||
        create_action_matcher('partner_environment_associations').call } do |subtabs|
      # Sub abas
      subtabs.dom_class = 'clearfix ui-tabs-nav'
      subtabs.item :environments, "Ambientes", partner_path(@partner),
        :highlights_on => Proc.new { action_matcher('partners','show').call ||
          create_action_matcher('partner_environment_associations').call },
        :class => 'ui-state-default',
        :link => { :class => 'icon-environment_16_18-before' }
      subtabs.item :admins, "Admins", partner_collaborators_path(@partner),
        :class => 'ui-state-default',
        :link => { :class => 'icon-environment_admin_16_18-before' }
      end
  end
end

