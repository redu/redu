module SearchHelper
  # Define o papel do usuário no Ambiente
  def user_environment_role(environment, user)
    uea = environment.user_environment_associations.select{ |assoc|
      assoc.user_id == user.id }.first

    role_icon(uea.try(:role))
  end

  # Define o papel do usuário no Curso
  def user_course_role(course, user)
    uca = course.user_course_associations.select{
      |assoc| assoc.user_id == user.id }.first

    role_icon(uca.try(:role))
  end

  def role_icon(role)
    if [0, 3, 4].include? role
      "manager"
    elsif role == 6
      "tutor"
    elsif role == 5
      "teacher"
    else
      "member"
    end
  end

  # Define a formatação da lista de administradores
  def show_administrators_list(collection)
    collection.collect { |admin|
      link_to(admin.display_name, user_path(admin),
              :title => admin.display_name)
    }.join(', ').html_safe
  end

  # Exibe o contador de amigos em comum entre parênteses somente quando há algum.
  def show_mutual_friends_counter(user)
    mutual_friends_counter = mutual_friends(user).length
    content_tag(:span, "(#{mutual_friends_counter})", :rel => "tooltip",
      :title => "Amigos em comum") if mutual_friends_counter > 0
  end

  # Verifica se a página atual é uma página individual de busca.
  def individual_search_page?
    current_page?(search_profiles_path) or (!params[:f].nil? and (params[:f].include? "ambientes" or params[:f].include? "cursos" or params[:f].include? "disciplinas"))
  end

  # Define se o link "Veja todos os resultados" deve ser mostrado.
  def show_see_all_results_link?(total_found)
    !individual_search_page? and total_found > Redu::Application.config.search_preview_results_per_page
  end

  # Retorna a quantidade correta de itens buscados dependendo da página.
  def search_results_counter(items)
    # Nas páginas individuais, o contador mostrado é a quantidade de itens visíveis na tela.
    if individual_search_page?
      items.count
    # Nas páginas restantes (busca geral e ambientes geral), o contador mostrado é o número total de itens encontrados.
    else
      items.total_entries
    end
  end
end