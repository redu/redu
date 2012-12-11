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
      # A navegação de Course não possui sidebar, bloco apenas para
      # manter o padrão
      sidebar.dom_class = 'local-nav'
      sidebar.selected_class = 'ui-state-active'
      sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
        tabs.dom_class = 'clearfix ui-tabs-nav'

        tabs.item :spaces, 'Disciplinas',
          environment_course_path(@course.environment, @course),
          :highlights_on => action_matcher({'courses' => ['show', 'preview']}),
          :class => 'ui-state-default',
          :link => { :class => "icon-space-gray_32_34-before" }
        tabs.item :account, 'Membros do Curso',
          environment_course_users_path(@course.environment, @course),
          :highlights_on => action_matcher({'courses' => ['admin_invitations'],
                                            'users' => ['index']}),
          :class => 'ui-state-default',
          :link => { :class => "icon-members-gray_32_34-before" } do |users_nav|
          # Sub abas
          users_nav.dom_class = 'clearfix ui-tabs-nav'
          users_nav.item :all, "Todos",
            environment_course_users_path(@course.environment, @course),
            :highlights_on => Proc.new { !params.has_key?(:role) &&
              action_matcher({'users' => ['index']}).call },
            :class => 'ui-state-default'
          users_nav.item :teachers, "Professores",
            environment_course_users_path(@course.environment, @course,
                                          :role => "teachers"),
            :highlights_on => Proc.new { params[:role].eql? "teachers" },
            :class => 'ui-state-default',
            :link => { :class => 'icon-teacher_16_18-before' }
          users_nav.item :tutors, "Tutores",
            environment_course_users_path(@course.environment, @course,
                                          :role => "tutors"),
            :highlights_on => Proc.new { params[:role].eql? "tutors" },
            :class => 'ui-state-default',
            :link => { :class => 'icon-tutor_16_18-before' }
          users_nav.item :students, "Alunos",
            environment_course_users_path(@course.environment, @course,
                                          :role => "students"),
            :highlights_on => Proc.new { params[:role].eql? "students" },
            :class => 'ui-state-default',
            :link => { :class => 'icon-member_16_18-before' }
          end
      end
    end
    primary.item :apps, 'Aplicativos', Redu::Application.config.redu_services[:apps][:url], :title => 'Aplicativos', :class => 'nav-global-button'
  end
end
