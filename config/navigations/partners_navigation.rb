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

    # A navegação global não é necessária, bloco apenas para
    # manter o padrão.
    primary.item :global_nav, 'Global Nav', home_user_path(current_user) do |sidebar|
      sidebar.dom_class = 'local-nav'
      sidebar.selected_class = 'ui-state-active'

      sidebar.item :sidebar, 'Parceiros', @partner ? partner_path(@partner) : partners_path do |tabs|
        # A navegação de Partner não possui tabs, bloco apenas para manter
        # o padrão
        tabs.item :tabs, 'Primary', home_user_path(current_user) do |subtabs|
          # Sub abas
          subtabs.dom_class = 'clearfix ui-tabs-nav'
          subtabs.item :environments, "Ambientes", partner_path(@partner),
            :highlights_on => Proc.new {
              action_matcher({'partners' => ['show']}).call ||
                (action_matcher('invoices' => ['index']).call && @client) ||
                (action_matcher('plans' => ['options']).call && @client) ||
                create_action_matcher('partner_environment_associations').call
            },
            :class => 'ui-state-default',
            :link => { :class => 'icon-environment_16_18-before' }
          subtabs.item :admins, "Admins", partner_collaborators_path(@partner),
            :class => 'ui-state-default',
            :link => { :class => 'icon-environment_admin_16_18-before' }
          subtabs.item :invoices, "Faturas", partner_invoices_path(@partner),
            :class => 'ui-state-default'
        end
      end
    end
  end
end
