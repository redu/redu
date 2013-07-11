# -*- encoding : utf-8 -*-
module SpacesNewNavigation
  def spaces_new_navigation(sidebar)
    sidebar.dom_class = 'nav-local'
    sidebar.selected_class = 'nav-local-item-active icon-arrow-right-nav-local-lightblue_11_32-after'

    sidebar.item :content, 'Aulas', space_path(@space),
      highlights_on: action_matcher({ 'spaces' => 'show',
                                      'subjects' => 'show',
                                      'lectures' => 'show'}),
      class: 'icon-subject_16_18-before nav-local-item',
      link: { class: 'nav-local-link' }
    sidebar.item :wall, 'Mural', mural_space_path(@space),
      class: 'icon-wall_16_18-before nav-local-item',
      link: { class: 'nav-local-link' }
    sidebar.item :files, 'Arquivos de Apoio', space_folders_path(@space),
      class: 'icon-file_16_18-before nav-local-item',
      link: { class: 'nav-local-link' }
    @space.canvas.each do |canvas|
      sidebar.item :canvas, canvas.current_name, space_canvas_path(@space, canvas),
        class: 'icon-app-lightblue_16_18-before nav-local-item',
        link: { class: 'nav-local-link text-truncate', rel: "tooltip",
          data: { placement: "right" },
          title: "#{canvas.current_name} por #{canvas.user.display_name}" }
    end
    sidebar.item :members, 'Membros',
      space_users_path(@space),
      class: 'icon-members_16_18-before nav-local-item',
      link: { class: 'nav-local-link' } do |filters|
      # A navegação de Space não possui tabs, bloco apenas para manter o padrão
      filters.item :filters, 'Filtros', user_path(current_user) do |filter|
        # Filtros.
        filter.dom_class = 'filters'
        filter.selected_class = 'filter-active'

        filter.item :all, 'Todos', space_users_path(@space),
          highlights_on: Proc.new {
            action_matcher({'users' => ['index']}).call &&
            !params.has_key?(:role) },
          class: 'filter icon-members-lightblue_16_18-before'
        filter.item :teachers, 'Professores',
          space_users_path(@space, role: 'teachers'),
          highlights_on: Proc.new { params[:role].eql? 'teachers' },
          class: 'filter icon-teacher-lightblue_16_18-before'
        filter.item :tutors, 'Tutores',
          space_users_path(@space, role: 'tutors'),
          highlights_on: Proc.new { params[:role].eql? 'tutors' },
          class: 'filter icon-tutor-lightblue_16_18-before'
        filter.item :students, 'Alunos',
          space_users_path(@space, role: 'students'),
          highlights_on: Proc.new { params[:role].eql? 'students' },
          class: 'filter icon-member-lightblue_16_18-before'
      end
    end
  end
end