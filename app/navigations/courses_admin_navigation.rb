# -*- encoding : utf-8 -*-
module CoursesAdminNavigation
  def courses_admin_navigation(sidebar)
    # A navegação de Course não possui sidebar, bloco apenas para manter o padrão
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      # Abas
      tabs.dom_class = 'tabs'
      tabs.selected_class = 'tab-active'
      tabs.item :infos, 'Informações',
        edit_environment_course_path(@environment, @header_course || @course),
        :highlights_on => action_matcher({'courses' => ['edit', 'update']}),
        :class => 'tab',
        :link => { :class => "tab-title icon-help-central-lightblue_16_18-before" }
      tabs.item :spaces, 'Disciplinas',
        admin_spaces_environment_course_path(@environment, @header_course || @course),
        :highlights_on => action_matcher({'courses' => ['admin_spaces'],
                                          'spaces' => ['new', 'create']}),
        :class => 'tab',
        :link => { :class => "tab-title icon-space-lightblue_16_18-before" },
        :details => { :text => 'nova disciplina',
                      :class => 'details ',
                      :if => action_matcher({'spaces' => ['new', 'create']})}
      tabs.item :members, 'Membros',
        admin_members_environment_course_path(@environment, @header_course || @course),
        :class => 'tab',
        :link => { :class => "tab-title icon-members-lightblue_16_18-before" } do |subtabs|
        # Sub abas
        subtabs.dom_class = 'clearfix ui-tabs-nav'
        subtabs.item :admin_members, "Lista",
          admin_members_environment_course_path(@environment, @course),
          :class => 'ui-state-default',
          :link => { :class => 'icon-list_16_18-before' }
        subtabs.item :moderate_members, "Moderação",
          admin_members_requests_environment_course_path(@environment, @course),
          :class => 'ui-state-default',
          :link => { :class => 'icon-moderation_16_18-before' }
        subtabs.item :invite_members, "Convites",
          admin_manage_invitations_environment_course_path(@environment, @course),
          :class => 'ui-state-default invite-tab',
          :link => { :class => 'icon-add-contact_16_18-before' }
      end
      tabs.item :reports, 'Relatórios',
        teacher_participation_report_environment_course_path(@environment, @course),
        :highlights_on => action_matcher({
          'courses' => ['teacher_participation_report']}),
          :class => 'tab',
          :link => { :class => "tab-title icon-reports-lightblue_16_18-before" }
    end
  end
end
