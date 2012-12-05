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
                  new_user_message_path(user), courses_index_path,
                  teach_index_path, "basic-guide", "tour-1")
  end
end
