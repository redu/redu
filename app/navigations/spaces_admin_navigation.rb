# -*- encoding : utf-8 -*-
module SpacesAdminNavigation
  def spaces_admin_navigation(sidebar)
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      tabs.dom_class = 'tabs'
      tabs.selected_class = 'tab-active'
      tabs.item :infos, 'Informações', edit_space_path(@space),
        :highlights_on => action_matcher({'spaces' => ['edit', 'update']}),
        :class => 'tab',
        :link => { :class => "tab-title icon-help-central-lightblue_16_18-before" }
      tabs.item :subject, 'Módulos e Aulas',
        admin_subjects_space_path(@space),
        :highlights_on => action_matcher({'subjects' => ['new', 'create', 'edit', 'update'],
                                          'spaces' => ['admin_subjects']}),
        :class => 'tab',
        :link => { :class => "tab-title icon-lecture-lightblue_16_18-before" },
        :details => { :text => "Novo",
                      :class => 'tab-sub-title legend',
                      :if => action_matcher({'subjects' => ['new', 'create']})}
      tabs.item :reports, 'Relatórios',
        students_participation_report_space_path(@space),
        :class => 'tab',
        :link => { :class => "tab-title icon-reports-lightblue_16_18-before" } do |subtabs|
          # Sub abas
          subtabs.dom_class = 'tab-buttons'
          subtabs.selected_class = 'tab-button-active'
          subtabs.item :students_report, "Alunos",
            students_participation_report_space_path(@space),
            :class => 'tab-button icon-list_16_18-before'
          subtabs.item :lecture_report, "Aulas",
            lecture_participation_report_space_path(@space),
            :class => 'tab-button icon-list_16_18-before'
          subtabs.item :subject_report, "Módulos",
            subject_participation_report_space_path(@space),
            :class => 'tab-button icon-list_16_18-before'
      end
    end
  end
end
