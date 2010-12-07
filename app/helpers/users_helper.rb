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
     link_to image_tag(annotation.lecture.thumb_url, :height => '24',
                       :width => '24'),
                       space_subject_lecture_path(subject.space, subject, annotation.lecture),
                       :rel => 'bookmark', :title => annotation.lecture.name
   else
     annotation.asset_name
     end
  end
end
