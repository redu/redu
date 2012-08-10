# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  navigation.selected_class = 'ui-state-active'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  navigation.autogenerate_item_ids = false

  # Caso alguma view que não tenha uma relação direta com usuário
  # utilize esta navegação (por utilizar o sidebar da home). Ex.: Partners
  @user = current_user unless @user

  # Define the primary navigation
  navigation.items do |primary|
    primary.dom_class = 'local-nav auxiliary-local-nav'
    primary.item :contacts, 'Contatos', user_friendships_path(current_user),
      :link => { :class => 'icon-contacts_16_18-before' }
  end
end
