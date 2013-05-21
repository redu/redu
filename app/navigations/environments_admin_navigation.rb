# -*- encoding : utf-8 -*-
module EnvironmentsAdminNavigation
  def environments_admin_navigation(sidebar)
    # A navegação de Environment não possui sidebar, bloco apenas para manter o padrão
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      # Abas
      tabs.dom_class = 'clearfix ui-tabs-nav'
      tabs.item :infos, 'Informações', edit_environment_path(@header_environment || @environment),
        :highlights_on => action_matcher({'environments' => ['edit', 'update']}),
        :class => 'ui-state-default',
        :link => { :class => "icon-bio_16_18-before" }
      tabs.item :infos, 'Cursos', admin_courses_environment_path(@header_environment || @environment),
        :highlights_on => action_matcher({'environments' => ['admin_courses'],
                                          'courses' => ['new', 'create']}),
        :class => 'ui-state-default',
        :link => { :class => "icon-course_16_18-before" },
        :details => { :text => 'novo', :class => 'details',
                      :if => action_matcher({'courses' => ['new', 'create']})}
      tabs.item :members, 'Membros', admin_members_environment_path(@header_environment || @environment),
        :highlights_on => action_matcher({'environments' => ['admin_members'],
                                          'roles' => ['index']}),
        :class => 'ui-state-default',
        :link => { :class => "icon-members_16_18-before" },
        :details => { :text => 'papéis', :class => 'details',
                      :if => action_matcher({'roles' => ['index']})}
    end
  end
end
