module UsersHelper
  def friends?(user, friend)
    Friendship.friends?(user, friend)
  end

  def random_greeting(user)
    greetings = ['Hello', 'Hola', 'Hi ', 'Yo', 'Welcome back,', 'Greetings',
        'Wassup', 'Aloha', 'Halloo']
    "#{greetings.sort_by {rand}.first} #{user.login}!"
  end

  # helper que imprime o link ou nome da aula, caso ela tenha sido removida
  # (persistimos as anotações do usuário mesmo quando a aula não existe mais)
  def link_to_or_name(annotation)
    if annotation.lecture
      subject = annotation.lecture.subject
      link_to image_tag(annotation.lecture.avatar.url(:thumb), :height => '24',
                        :width => '24'),
                        space_subject_lecture_path(subject.space, subject, annotation.lecture),
                        :rel => 'bookmark', :title => annotation.lecture.name
    else
      annotation.asset_name
    end
  end

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
end
