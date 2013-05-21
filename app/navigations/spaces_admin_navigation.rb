# -*- encoding : utf-8 -*-
module SpacesAdminNavigation
  def spaces_admin_navigation(sidebar)
    sidebar.dom_class = 'local-nav'
    sidebar.selected_class = '' # auto_highlight = false não funciona

    sidebar.item :content, 'Conteúdo', space_path(@space),
      :highlights_on => action_matcher({ 'spaces' => 'show',
                                         'subjects' => 'show' }),
      :link => { :class => 'icon-subject_16_18-before' }
    sidebar.item :wall, 'Mural', mural_space_path(@space),
      :link => { :class => 'icon-wall_16_18-before' }
    sidebar.item :files, 'Arquivos de Apoio', space_folders_path(@space),
      :link => { :class => 'icon-file_16_18-before' }
    sidebar.item :members, "Membros: #{@space.users.count}",
      space_users_path(@space), :class => 'big-separator',
      :link => { :class => 'icon-members_16_18-before' } do |tabs|
      # Abas
      tabs.dom_class = 'clearfix ui-tabs-nav'
      tabs.item :infos, 'Informações',
        edit_space_path(@space),
        :highlights_on => action_matcher({'spaces' => ['edit', 'update']}),
        :class => 'ui-state-default',
        :link => { :class => "icon-bio_16_18-before" }
      tabs.item :subject, 'Módulos',
        admin_subjects_space_path(@space),
        :highlights_on => action_matcher({'subjects' => ['new', 'create', 'edit', 'update'],
                                          'spaces' => ['admin_subjects']}),
        :class => 'ui-state-default',
        :link => { :class => "icon-subject_16_18-before" },
        :details => { :text => "novo módulo",
                      :class => 'details ',
                      :if => action_matcher({'subjects' => ['new', 'create']})}
      tabs.item :members, 'Membros',
        admin_members_space_path(@space),
        :class => 'ui-state-default',
        :link => { :class => "icon-members_16_18-before" }
      tabs.item :reports, 'Relatórios',
        students_participation_report_space_path(@space),
        :class => 'ui-state-default',
        :link => { :class => "icon-bio_16_18-before" } do |subtabs|
        # Sub abas
        subtabs.dom_class = 'clearfix ui-tabs-nav'
        subtabs.item :students_report, "Alunos",
          students_participation_report_space_path(@space),
          :class => 'ui-state-default',
          :link => { :class => 'icon-list_16_18-before' }
        subtabs.item :lecture_report, "Aulas",
          lecture_participation_report_space_path(@space),
          :class => 'ui-state-default',
          :link => { :class => 'icon-list_16_18-before' }
        subtabs.item :subject_report, "Módulos",
          subject_participation_report_space_path(@space),
          :class => 'ui-state-default',
          :link => { :class => 'icon-list_16_18-before' }
      end
    end
  end
end
