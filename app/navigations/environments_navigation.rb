# -*- encoding : utf-8 -*-
module EnvironmentsNavigation
  def environments_navigation(sidebar)
    # A navegação de Environment não possui sidebar, bloco apenas para manter o padrão
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      # Abas
      tabs.dom_class = 'tabs'
      tabs.selected_class = 'tab-active'
      tabs.item :courses, 'Cursos', environment_path(@environment),
        :highlights_on => action_matcher({'environments' => ['show', 'preview']}),
        class: 'tab',
        link: { class: "tab-title icon-course-lightblue_16_18-before" }
      tabs.item :account, 'Membros', environment_users_path(@environment),
        class: 'tab',
        link: { class: "tab-title icon-members-lightblue_16_18-before" } do |users_nav|
        # Sub abas
        users_nav.dom_class = 'filters'
        users_nav.selected_class = 'filter-active'
        users_nav.item :all, "Todos", environment_users_path(@environment),
          :highlights_on => Proc.new { !params.has_key?(:role) &&
                                       action_matcher({'users' => ['index']}).call },
          class: 'filter icon-members-lightblue_16_18-before'
        users_nav.item :teachers, "Professores",
          environment_users_path(@environment, :role => "teachers"),
          :highlights_on => Proc.new { params[:role].eql? "teachers" },
          class: 'filter icon-teacher-lightblue_16_18-before'
        users_nav.item :tutors, "Tutores",
          environment_users_path(@environment, :role => "tutors"),
          :highlights_on => Proc.new { params[:role].eql? "tutors" },
          class: 'filter icon-tutor-lightblue_16_18-before'
        users_nav.item :students, "Alunos",
          environment_users_path(@environment, :role => "students"),
          :highlights_on => Proc.new { params[:role].eql? "students" },
          class: 'filter icon-member-lightblue_16_18-before'
      end
    end
  end
end
