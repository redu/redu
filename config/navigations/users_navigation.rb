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
    primary.dom_class = 'nav-global-buttons'
    primary.selected_class = 'nav-global-button-active'

    primary.item :start, 'Início', home_user_path(current_user), :title => 'Início', :class => 'nav-global-button' do |sidebar|
      sidebar.dom_class = 'local-nav'
      sidebar.selected_class = 'ui-state-active'

      sidebar.item :overview, 'Visão Geral', home_user_path(current_user),
        :link => { :class => 'icon-home_16_18-before' }
      sidebar.item :wall, 'Meu Mural', my_wall_user_path(current_user),
        :link => { :class => 'icon-wall_16_18-before' }

      sidebar.item :messages, 'Mensagens', user_messages_path(current_user),
        :link => { :class => 'icon-message_16_18-before'} do |messages_env|
        messages_env.dom_class = 'clearfix ui-tabs-nav'
        messages_env.item :received, 'Recebidas', user_messages_path(@user),
          :highlights_on => Proc.new {
          action_matcher({'messages' => ['index', 'show']}).call &&
          (action_matcher({'messages' => ['show']}).call ?
           @message.sender != @user : true)
        },
          :class => 'ui-state-default',
          :link => { :class => 'icon-message_16_18-before'},
          :details => { :text => 'visualização', :class => 'details',
            :if => Proc.new { action_matcher({'messages' => ['show']}).call &&
              @message.sender != @user } }
        messages_env.item :sent, 'Enviadas', index_sent_user_messages_path(@user),
          :highlights_on => Proc.new {
          action_matcher({'messages' => ['index_sent', 'show']}).call &&
          (action_matcher({'messages' => ['show']}).call ?
           @message.sender == @user : true)
        },
          :class => 'ui-state-default',
          :link => { :class => 'icon-answer_message_16_18-before' },
          :details => { :text => 'visualização', :class => 'details',
            :if => Proc.new { action_matcher({'messages' => ['show']}).call &&
              @message.sender == @user } }
        messages_env.item :new, "Nova", new_user_message_path(@user),
          :highlights_on => create_action_matcher('messages'),
          :class => 'ui-state-default',
          :link => { :class => 'icon-add_message_16_18-before' }
        end

      sidebar.item :environments, 'Ambientes', user_environments_path(@user),
        :link => { :class => 'icon-environment_16_18-before' }

      sidebar.item :configurations, 'Configurações',
        edit_user_path(current_user),
        :link => { :class => 'icon-manage_16_18-before' } do |config_nav|
        config_nav.dom_class = 'clearfix ui-tabs-nav'
        config_nav.item :edit, 'Perfil', edit_user_path(@user),
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
        config_nav.item :account, 'Conta', account_user_path(@user),
          :highlights_on => action_matcher({'users' => ['account', 'update_account']}),
          :class => 'ui-state-default',
          :link => { :class => 'icon-account_16_18-before' }
        config_nav.item :plans, 'Planos', user_plans_path(@user),
          :highlights_on => Proc.new { action_matcher({'plans' => ['index', 'options'], 'invoices' => ['index']}).call && @partner.nil? },
          :class => 'ui-state-default',
          :link => { :class => 'icon-plans_16_18-before'},
          :details => { :text => 'detalhes', :class => "details",
            :if => action_matcher({'invoices' => ['index']}) }
      end
      sidebar.item :contacts, 'Meus Contatos', user_friendships_path(current_user),
        :link => { :class => 'icon-contacts_16_18-before' } do |tab|
        tab.item :invite_friends, 'Convide seus amigos', new_user_friendship_path(@user)
      end
    end
    primary.item :teach, 'Ensine', teach_index_path, :title => 'Ensine', :class => 'nav-global-button', :highlights_on => action_matcher({'environments' => 'create'})
    primary.item :courses, 'Cursos', courses_index_path, :title => 'Cursos', :class => 'nav-global-button'
    primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url], :title => 'Aplicativos', :class => 'nav-global-button'
  end
end
