# -*- encoding : utf-8 -*-
module EnvironmentsAdminNavigation
  def environments_admin_navigation(sidebar)
    # A navegação de Environment não possui sidebar, bloco apenas para manter o padrão
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      @environment = @header_environment || @environment
      # Abas
      tabs.dom_class = 'tabs'
      tabs.selected_class = 'tab-active'
      tabs.item :infos, 'Informações', edit_environment_path(@environment),
        :highlights_on => action_matcher({'environments' => ['edit', 'update']}),
        :class => 'tab',
        :link => { :class => "tab-title icon-help-central-lightblue_16_18-before" }
      tabs.item :infos, 'Cursos', admin_courses_environment_path(@environment),
        :highlights_on => action_matcher({'environments' => ['admin_courses'],
                                          'courses' => ['new', 'create']}),
        :class => 'tab',
        :link => { :class => "tab-title icon-course-lightblue_16_18-before" },
        :details => { :text => 'novo', :class => 'details',
                      :if => action_matcher({'courses' => ['new', 'create']})}
      tabs.item :members, 'Papéis', admin_members_environment_path(@environment),
        :highlights_on => action_matcher({'environments' => ['admin_members'],
                                          'roles' => ['index']}),
        :class => 'tab',
        :link => { :class => "tab-title icon-members-lightblue_16_18-before" }
      # TODO: Link para nova aba de licenças e planos.
      tabs.item :plans, 'Licenças / Faturas', admin_plans_environment_path(@environment),
        :highlights_on => action_matcher({'environments' => ['admin_plans']}),
        class: 'tab',
        link: { class: "tab-title icon-plan-lightblue_16_18-before" }
    end
  end
end
