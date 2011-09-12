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
    primary.item :received, 'Recebidas', user_messages_path(@user),
      :highlights_on => Proc.new {
      action_matcher('messages', ['index', 'show']).call &&
      (action_matcher('messages', 'show').call ?
       @message.sender != @user : true)
    },
      :class => 'ui-state-default',
      :link => { :class => 'icon-message_16_18-before'},
      :details => { :text => 'visualização', :class => 'details',
        :if => Proc.new { action_matcher('messages', 'show').call &&
        @message.sender != @user } }
    primary.dom_class = 'clearfix ui-tabs-nav'
    primary.item :sent, 'Enviadas', index_sent_user_messages_path(@user),
      :highlights_on => Proc.new {
      action_matcher('messages', ['index_sent', 'show']).call &&
      (action_matcher('messages', 'show').call ?
       @message.sender == @user : true)
    },
      :class => 'ui-state-default',
      :link => { :class => 'icon-answer_message_16_18-before' },
      :details => { :text => 'visualização', :class => 'details',
        :if => Proc.new { action_matcher('messages', 'show').call &&
          @message.sender == @user } }
    primary.item :new, "Nova", new_user_message_path(@user),
      :highlights_on => create_action_matcher('messages'),
      :class => 'ui-state-default',
      :link => { :class => 'icon-add_message_16_18-before' }
  end
end
