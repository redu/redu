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
      sidebar.item :messages, 'Mensagens', user_messages_path(@user), :class => 'icon-message_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Mensagens' } do |messages_tab|
        messages_tab.dom_class = 'tabs'
        messages_tab.selected_class = 'tab-active'

        messages_tab.item :received, 'Recebidas', user_messages_path(@user),
          :highlights_on => Proc.new {
            action_matcher({'messages' => ['index', 'show']}).call &&
            (action_matcher({'messages' => ['show']}).call ?
             @message.sender != @user : true)
          },
          :class => 'tab',
          :link => { :class => 'tab-title icon-message_16_18-before',
                     :title => 'Recebidas' },
          :details => { :text => 'Visualização', :class => 'tab-sub-title legend',
                        :if => Proc.new { action_matcher({'messages' => ['show']}).
                                          call && @message.sender != @user } }

        messages_tab.item :sent, 'Enviadas', index_sent_user_messages_path(@user),
          :highlights_on => Proc.new {
            action_matcher({'messages' => ['index_sent', 'show']}).call &&
            (action_matcher({'messages' => ['show']}).call ?
             @message.sender == @user : true)
          },
          :class => 'tab',
          :link => { :class => 'tab-title icon-message-sent_16_18-before',
                     :title => 'Enviadas' },
          :details => { :text => 'Visualização', :class => 'tab-sub-title legend',
                        :if => Proc.new { action_matcher({'messages' => ['show']}).
                                          call && @message.sender == @user } }
      end
      sidebar.item :environments, 'Ambientes', user_environments_path(@user), :class => 'icon-environment_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Ambientes' }
      sidebar.item :settings, 'Configurações', edit_user_path(@user), :class => 'icon-manage_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Configurações' } do |settings_tab|
        settings_tab.dom_class = 'tabs'
        settings_tab.selected_class = 'tab-active'

        settings_tab.item :edit, 'Perfil', edit_user_path(@user),
          :highlights_on => update_action_matcher('users'),
          :class => 'tab',
          :link => { :class => 'tab-title icon-profile_16_18-before',
                     :title => 'Perfil' } do |profile_subtab|
          # Sub abas
          profile_subtab.dom_class = 'tab-buttons'
          profile_subtab.selected_class = 'tab-button-active'

          profile_subtab.item :biography, "Biografia", edit_user_path(@user),
            :highlights_on => update_action_matcher('users'),
            :class => 'tab-button icon-biography-_16_18-before',
            :title => 'Biografia'
          profile_subtab.item :curriculum, "Currículo", curriculum_user_path(@user),
            :class => 'tab-button icon-curriculum_16_18-before',
            :title => 'Currículo'
        end
        settings_tab.item :account, 'Conta', account_user_path(@user),
          :highlights_on => action_matcher({'users' => ['account', 'update_account']}),
          :class => 'tab',
          :link => { :class => 'tab-title icon-account_16_18-before',
                     :title => 'Conta' }
        settings_tab.item :plans, 'Planos', user_plans_path(@user),
          :highlights_on => Proc.new { action_matcher({'plans' => ['index', 'options'], 'invoices' => ['index']}).call && @partner.nil? },
          :class => 'tab',
          :link => { :class => 'tab-title icon-plan_16_18-before',
                     :title => 'Planos' },
          :details => { :text => 'detalhes', :class => 'tab-sub-title legend',
            :if => action_matcher({'invoices' => ['index']}) }
      end
      sidebar.item :oauth_clients, 'Aplicativos', new_user_oauth_client_path(@user), :class => 'nav-local-item icon-app-lightblue_16_18-before ', :link => { :class => 'nav-local-link link-target', :title => 'Aplicativos' } do |apps_tab|
        apps_tab.dom_class = 'tabs'
        apps_tab.selected_class = 'tab-active'

        apps_tab.item :new_app, 'Novo Aplicativo', new_user_oauth_client_path(@user), :class => 'tab',
          :highlights_on => action_matcher({ 'oauth_clients' => ['new', 'create'] }),
          :link => { :class => 'tab-title', :title => 'Novo Aplicativo' }
        apps_tab.item :my_apps, 'Meus Aplicativos', user_oauth_clients_path(@user), :class => 'tab',
          :highlights_on => action_matcher({ 'oauth_clients' => ['show', 'index', 'edit', 'update'] }),
          :link => { :class => 'tab-title', :title => 'Meus Aplicativos' },
          :details => { :text => 'Visualização', :class => 'tab-sub-title legend',
                        :if => action_matcher({ 'oauth_clients' => ['show', 'edit',
        'update'] }) }
      end
      sidebar.item :my_contacts, 'Meus Contatos', user_friendships_path(@user), :class => 'icon-contacts_16_18-before nav-local-item', :link => { :class => 'nav-local-link link-target', :title => 'Meus Contatos' }
    end
    primary.item :teach, 'Ensine', teach_index_path, :title => 'Ensine', :class => 'nav-global-button'
    primary.item :courses, 'Cursos', courses_index_path, :title => 'Cursos', :class => 'nav-global-button'
    primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url], :title => 'Aplicativos', :class => 'nav-global-button'
  end
end
