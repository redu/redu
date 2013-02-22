module PartnersNavigation
  def partners_navigation(sidebar)
    sidebar.dom_class = 'local-nav'
    sidebar.selected_class = 'ui-state-active'

    sidebar.item :sidebar, 'Parceiros', @partner ? partner_path(@partner) : partners_path do |tabs|
      # A navegação de Partner não possui tabs, bloco apenas para manter o padrão
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
