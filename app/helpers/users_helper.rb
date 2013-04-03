module UsersHelper
  # criação de novos campos para social_network através do fields_for
  def new_social_network(f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s + "/" + association.to_s.singularize + "_fields",
             :f => builder)
    end
  end

  # gera uma url, adicionando http:// ao começo da url se não tiver
  def generate_url(url)
    if url =~ /^((http|https):\/\/)/
      url
    else
      "http://" + url
    end
  end

  def explored_all_tips?(user)
    user.settings.visited?(edit_user_path(user),new_user_friendship_path(user),
                  user_messages_path(user), environments_index_path,
                  teach_index_path, "basic-guide", "tour-1")
  end

  def what_is_missing_box_display(user)
    if !user.settings.visited?("what-is-missing") && !explored_all_tips?(user)
      "block"
    else
      "none"
    end
  end

  def learn_environments_display(user)
    if user.settings.visited?("learn-environments")
      "none"
    else
      "block"
    end
  end

  def explore_sidebar_display(user)
    if user.settings.visited_at_least_one?("what-is-missing", "tour-1",
                                           "learn-environments")
      "block"
    else
      "none"
    end
  end

  def what_is_missing_link_display(user)
    if !user.settings.visited?("what-is-missing") || explored_all_tips?(user)
      "none"
    else
      "block"
    end
  end

  # Dois usuários são amigos quando eles tem um 'friendship'
  # aceito e eles não são a mesma pessoa
  def is_friend?(user, someone = current_user)
    user.friends?(someone) and !user.is?(someone)
  end

  # Atual 'friendship' para dois usuários
  def current_friendship(user, someone = current_user)
    user.friendship_for someone
  end

  # Amigos em comum para dois usuários
  def mutual_friends(user, someone = current_user)
    user.friends_in_common_with(someone)
  end

  # Retorna o título correto do formulário de adição/edição em currículo.
  def form_curriculum_title(curriculum_item)
    if curriculum_item.new_record?
      action = "Novo"
    else
      action = "Editando"
    end

    "#{action} item"
  end

  # Retorna o texto correto do botão de submissão do formulário de adição/edição em currículo.
  def form_curriculum_submit_text(curriculum_item)
    if curriculum_item.new_record?
      action = "Adicionar"
    else
      action = "Salvar"
    end

    "#{action} item"
  end
end
