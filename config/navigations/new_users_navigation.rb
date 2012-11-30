# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  navigation.autogenerate_item_ids = false

  # Define the primary navigation
  navigation.items do |primary|
    primary.dom_class = 'nav-global-buttons'
    primary.selected_class = 'nav-global-button-active'

    primary.item :start, 'Início', home_user_path(current_user), :title => 'Início', :class => 'nav-global-button' do |sidebar|
      sidebar.dom_class = 'nav-local'
      sidebar.selected_class = 'nav-local-item-active icon-arrow-right-nav-local-lightblue_11_32-after'

      sidebar.item :overview, 'Visão Geral', home_user_path(@user), :class => 'icon-home_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Visão Geral' }
      sidebar.item :my_wall, 'Meu Mural', my_wall_user_path(@user), :class => 'icon-wall_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Meu Mural' }
      sidebar.item :messages, 'Mensagens', user_messages_path(@user), :class => 'icon-message_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Mensagens' }
      sidebar.item :environments, 'Ambientes', application_path, :class => 'icon-environment_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Ambientes' }
      sidebar.item :settings, 'Configurações', edit_user_path(@user), :class => 'icon-manage_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Configurações' }
      sidebar.item :my_contacts, 'Meus Contatos', user_friendships_path(@user), :class => 'icon-contacts_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Meus Contatos' }
    end
    primary.item :teach, 'Ensine', teach_index_path, :title => 'Ensine', :class => 'nav-global-button'
    primary.item :courses, 'Cursos', courses_index_path, :title => 'Cursos', :class => 'nav-global-button'
    primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url], :title => 'Aplicativos', :class => 'nav-global-button'
  end
end
