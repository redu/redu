# -*- encoding : utf-8 -*-
module LecturesNavigation
  # Cópia da navegação de disciplina com adição da aula atual.
  def lectures_navigation(sidebar)
    sidebar.dom_class = 'nav-local lights-fade'
    item_class = 'nav-local-item'
    link_class = 'nav-local-link'
    truncate_class = 'text-truncate'
    tooltip_direction = 'right'

    sidebar.item :content, 'Aulas', @lecture.subject.space,
      highlights_on: action_matcher({ 'lectures' => 'show' }),
      class: "#{ item_class } icon-lecture_16_18-before",
      link: { class: link_class }
    sidebar.item :lecture, "#{ @lecture.position }. #{ @lecture.name }",
      class: "#{ item_class } icon-arrow-right-squared-gray_16_18-before",
      link: { class: "#{ link_class } #{ truncate_class } nav-local-lecture-link",
        rel: 'tooltip', data: { placement: tooltip_direction }, title: @lecture.name }
    sidebar.item :wall, 'Mural', mural_space_path(@lecture.subject.space),
      class: "#{ item_class } icon-wall_16_18-before",
      link: { class: link_class }
    sidebar.item :files, 'Arquivos de Apoio', space_folders_path(@lecture.subject.space),
      class: "#{ item_class } icon-file_16_18-before",
      link: { class: link_class }
    @lecture.subject.space.canvas.each do |canvas|
      sidebar.item :canvas, canvas.current_name, space_canvas_path(@lecture.subject.space, canvas),
        class: "#{ item_class } icon-app-lightblue_16_18-before",
        link: { class: "#{ link_class } #{ truncate_class }", rel: 'tooltip',
          data: { placement: tooltip_direction },
          title: "#{canvas.current_name} por #{canvas.user.display_name}" }
    end
    sidebar.item :members, 'Membros',
      space_users_path(@lecture.subject.space),
      class: "#{ item_class } icon-members_16_18-before",
      link: { class: link_class }
  end
end