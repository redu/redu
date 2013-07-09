# -*- encoding : utf-8 -*-
module CoursesNavigation
  def courses_navigation(sidebar)
    # A navegação de Course não possui sidebar, bloco apenas para manter o padrão
    sidebar.dom_class = 'local-nav'
    sidebar.selected_class = 'ui-state-active'
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      # Abas
      tabs.dom_class = 'tabs'
      tabs.selected_class = 'tab-active'
      tabs.item :spaces, 'Disciplinas',
        environment_course_path(@course.environment, @course),
        :highlights_on => action_matcher({'courses' => ['show', 'preview']}),
        class: 'tab',
        link: { class: "tab-title icon-space-lightblue_16_18-before" }
      tabs.item :account, 'Membros do Curso',
        environment_course_users_path(@course.environment, @course),
        :highlights_on => action_matcher({'courses' => ['admin_invitations'],
                                          'users' => ['index']}),
        class: 'tab',
        link: { class: "tab-title icon-members-lightblue_16_18-before" } do |users_nav|
        # Sub abas
        users_nav.dom_class = 'filters'
        users_nav.selected_class = 'filter-active'
        users_nav.item :all, "Todos",
          environment_course_users_path(@course.environment, @course),
          :highlights_on => Proc.new { !params.has_key?(:role) &&
                                       action_matcher({'users' => ['index']}).call },
          class: 'filter icon-members-lightblue_16_18-before'
        users_nav.item :teachers, "Professores",
          environment_course_users_path(@course.environment, @course,
                                        :role => "teachers"),
          :highlights_on => Proc.new { params[:role].eql? "teachers" },
          class: 'filter icon-teacher-lightblue_16_18-before'
        users_nav.item :tutors, "Tutores",
          environment_course_users_path(@course.environment, @course,
                                        :role => "tutors"),
          :highlights_on => Proc.new { params[:role].eql? "tutors" },
          class: 'filter icon-tutor-lightblue_16_18-before'
        users_nav.item :students, "Alunos",
          environment_course_users_path(@course.environment, @course,
                                        :role => "students"),
          :highlights_on => Proc.new { params[:role].eql? "students" },
          class: 'filter icon-member-lightblue_16_18-before'
      end
    end
  end
end
