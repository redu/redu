# -*- encoding : utf-8 -*-
module SpacesNavigation
  def spaces_navigation(sidebar)
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
      sidebar.item :canvas, render_local_nav_canvas(canvas),
        space_canvas_path(@space, canvas),
        :link => { :class => 'icon-app_16_18-before local-nav-item-canvas-icon' }
    end
    sidebar.item :members, "Membros: #{@space.users.count}",
      space_users_path(@space), :class => 'big-separator',
      :link => { :class => 'icon-members_16_18-before' } do |tabs|
      # A navegação de Space não possui tabs, bloco apenas para manter o padrão
      tabs.item :tabs, 'Tabs', user_path(current_user),
        :class => 'ui-state-default' do |users_nav|
        # Sub abas
        users_nav.dom_class = 'clearfix ui-tabs-nav'
        users_nav.item :all, "Todos", space_users_path(@space),
          :highlights_on => Proc.new {
            action_matcher({'users' => ['index']}).call &&
            !params.has_key?(:role) },
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
end
