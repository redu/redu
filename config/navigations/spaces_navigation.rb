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
    primary.dom_class = 'nav-global-buttons'
    primary.selected_class = 'nav-global-button-active'

    primary.item :start, 'Início', home_user_path(current_user), :title => 'Início', :class => 'nav-global-button'
    primary.item :teach, 'Ensine', teach_index_path, :title => 'Ensine', :class => 'nav-global-button'
    primary.item :courses, 'Cursos', courses_index_path, :title => 'Cursos', :class => 'nav-global-button' do |sidebar|
      sidebar.dom_class = 'local-nav'
      sidebar.item :content, 'Conteúdo', space_path(@space),
        :highlights_on => action_matcher({ 'spaces' => 'show',
                                           'subjects' => 'show',
                                           'lectures' => 'show'}),
        :link => { :class => 'icon-subject_16_18-before' }
      sidebar.item :wall, 'Mural', mural_space_path(@space),
        :link => { :class => 'icon-wall_16_18-before' }
      sidebar.item :files, 'Arquivos de Apoio', space_folders_path(@space),
        :link => { :class => 'icon-file_16_18-before' }
      @space.canvas.each do |canvas|
        sidebar.item :canvas, canvas.client_application.name,
          space_canvas_path(@space, canvas),
          :link => { :class => 'icon-file_16_18-before' }
      end
      sidebar.item :members, "Membros: #{@space.users.count}",
        space_users_path(@space), :class => 'big-separator',
        :link => { :class => 'icon-members_16_18-before' } do |tabs|
          # A navegação de Space não possui tabs, bloco apenas para manter
          # o padrão
          tabs.item :tabs, 'Tabs', user_path(current_user),
            :class => 'ui-state-default' do |users_nav|
            # Sub abas
            users_nav.dom_class = 'clearfix ui-tabs-nav'
            users_nav.item :all, "Todos", space_users_path(@space),
              :highlights_on => Proc.new {
              action_matcher({'users' => ['index']}).call && !params.has_key?(:role)
            },
              :class => 'ui-state-default'
            users_nav.item :teachers, "Professores",
              space_users_path(@space, :role => "teachers"),
              :highlights_on => Proc.new { params[:role].eql? "teachers" },
              :class => 'ui-state-default',
              :link => { :class => 'icon-teacher_16_18-before' }
            users_nav.item :tutors, "Tutores",
              space_users_path(@space, :role => "tutors"),
              :highlights_on => Proc.new { params[:role].eql? "tutors" },
              :class => 'ui-state-default',
              :link => { :class => 'icon-tutor_16_18-before' }
            users_nav.item :students, "Alunos",
              space_users_path(@space, :role => "students"),
              :highlights_on => Proc.new { params[:role].eql? "students" },
              :class => 'ui-state-default',
              :link => { :class => 'icon-member_16_18-before' }
            end
      end
    end
    primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url], :title => 'Aplicativos', :class => 'nav-global-button'
  end
end
