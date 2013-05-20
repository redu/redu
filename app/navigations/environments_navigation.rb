# -*- encoding : utf-8 -*-
module EnvironmentsNavigation
  def environments_navigation(sidebar)
    # A navegação de Environment não possui sidebar, bloco apenas para manter o padrão
    sidebar.item :sidebar, 'Sidebar', home_path do |tabs|
      # Abas
      tabs.dom_class = 'clearfix ui-tabs-nav'
      tabs.item :courses, 'Cursos', environment_path(@environment),
        :highlights_on => action_matcher({'environments' => ['show', 'preview']}),
        :class => 'ui-state-default',
        :link => { :class => "icon-course-gray_32_34-before" }
      tabs.item :account, 'Membros', environment_users_path(@environment),
        :class => 'ui-state-default',
        :link => { :class => "icon-members-gray_32_34-before" } do |users_nav|
        # Sub abas
        users_nav.dom_class = 'clearfix ui-tabs-nav'
        users_nav.item :all, "Todos", environment_users_path(@environment),
          :highlights_on => Proc.new { !params.has_key?(:role) &&
                                       action_matcher({'users' => ['index']}).call },
          :class => 'ui-state-default'
        users_nav.item :teachers, "Professores",
          environment_users_path(@environment, :role => "teachers"),
          :highlights_on => Proc.new { params[:role].eql? "teachers" },
          :class => 'ui-state-default',
          :link => { :class => 'icon-teacher_16_18-before' }
        users_nav.item :tutors, "Tutores",
          environment_users_path(@environment, :role => "tutors"),
          :highlights_on => Proc.new { params[:role].eql? "tutors" },
          :class => 'ui-state-default',
          :link => { :class => 'icon-tutor_16_18-before' }
        users_nav.item :students, "Alunos",
          environment_users_path(@environment, :role => "students"),
          :highlights_on => Proc.new { params[:role].eql? "students" },
          :class => 'ui-state-default',
          :link => { :class => 'icon-member_16_18-before' }
      end
    end
  end
end
