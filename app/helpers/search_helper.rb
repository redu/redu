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
    when "manager" then raw(t 'classy_enum.role.admin')
    when "teacher" then raw(t 'classy_enum.role.teacher')
    when "tutor" then raw(t 'classy_enum.role.tutor')
    when "member" then raw(t 'classy_enum.role.member')
    end
  end

  # Define a formatação da lista de administradores
  def show_administrators_list(collection)
    collection.collect { |admin|
      link_to(admin.display_name, user_path(admin),
              :title => admin.display_name)
    }.join(', ').html_safe
  end

  # Define a formatação da lista de professores
  def show_teachers_list(collection)
    collection.collect { |teacher|
      link_to(teacher.display_name, user_path(teacher),
              :title => teacher.display_name)
    }.join(', ').html_safe
  end

  # Exibe o contador de amigos em comum entre parênteses somente quando há algum.
  def show_mutual_friends_counter(user)
    content_tag(:span, parentize(mutual_friends(user).length), :rel => "tooltip",
      :title => "Amigos em comum")
  end

  # Define se o link "Veja todos os resultados" deve ser mostrado.
  def show_see_all_results_link?(total_found)
    !@individual_page and total_found > Redu::Application.config.search_preview_results_per_page
  end

  # Retorna a quantidade correta de itens buscados dependendo da página.
  def search_results_counter(items)
    # Nas páginas individuais, o contador mostrado é a quantidade de itens visíveis na tela.
    if @individual_page
      items.count
    # Nas páginas restantes (busca geral e ambientes geral), o contador mostrado é o número total de itens encontrados.
    else
      items.total_count
    end
  end

  # Só permite mostrar as disciplinas do curso se o usuário tem acesso ao mesmo
  # e se existe pelo menos uma disciplina para mostrar
  def show_course_spaces(course)
    course.spaces.length > 0 && current_user.has_access_to?(course)
  end
end
