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

  # Define o ícone a ser usado dependendo do papel.
  def role_icon(role)
    case role
    when (Role[:environment_admin] or Role[:course_admin] or Role[:admin]) then "manager"
    when Role[:teacher] then "teacher"
    when Role[:tutor] then "tutor"
    when Role[:member] then "member"
    end
  end

  # Defino o nome do papel de acordo com o ícone usado.
  def role_icon_to_text(role_icon)
    case role_icon
    when "manager" then raw(t 'activerecord.attributes.role.environment_admin')
    when "teacher" then raw(t 'activerecord.attributes.role.teacher')
    when "tutor" then raw(t 'activerecord.attributes.role.tutor')
    when "member" then raw(t 'activerecord.attributes.role.member')
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
    current_page?(search_profiles_path) or (params[:f].size == 1 if params[:f])
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
      items.total_count
    end
  end

  # Filtra disciplinas pelo usuário
  def filter_spaces(collection)
    SpaceSearch.filter_my_spaces(collection, current_user)
  end
end
