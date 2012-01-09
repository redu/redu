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
    # A navegação de Partner não possui sidebar, bloco apenas para
    # manter o padrão
    primary.item :sidebar, 'Sidebar', home_path do |tabs|
      # A navegação de Partner não possui tabs, bloco apenas para manter
      # o padrão
      tabs.item :tabs, 'Primary', notifications_user_path(@user) do |subtabs|
        # Sub abas
        subtabs.dom_class = 'clearfix ui-tabs-nav'
        subtabs.item :notifications, "Notificações", notifications_user_path(@user),
            :class => 'ui-state-default',
            :link => { :class => 'icon-wall_16_18-before' }
        subtabs.item :invites, "Convites", invitations_user_path(@user),
          :class => 'ui-state-default green',
          :link => { :class => 'icon-add-contact_16_18-before' }
      end
    end
  end
end
