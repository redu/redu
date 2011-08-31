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
    primary.item :edit, 'Perfil', edit_user_path(@user),
      :highlights_on => update_action_matcher('users'),
      :class => 'ui-state-default',
      :link => { :class => "icon-profile_16_18-before"} do |edit_nav|
      # Sub abas
      edit_nav.dom_class = 'clearfix ui-tabs-nav'
      edit_nav.item :biography, "Biografia", edit_user_path(@user),
        :highlights_on => update_action_matcher('users'),
        :class => 'ui-state-default',
        :link => { :class => 'icon-bio_16_18-before' }
      edit_nav.item :curriculum, "Currículo", curriculum_user_path(@user),
        :class => 'ui-state-default',
        :link => { :class => 'icon-cv_16_18-before' }
      end
    primary.item :account, 'Conta', account_user_path(@user),
      :class => 'ui-state-default',
      :link => { :class => 'icon-account_16_18-before' }
    primary.item :plans, 'Planos', user_plans_path(@user),
      :class => 'ui-state-default',
      :link => { :class => 'icon-plans_16_18-before'}
  end
end
