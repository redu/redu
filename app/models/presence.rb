class Presence
  # Responsável pela autenticação no Pusher e carregamento da lista de contatos

  attr_reader :contacts, :channels

  def initialize(user)
    @user = user
    @contacts = list_of_contacts || []
    @contacts_by_pre = build_index(@contacts)
    @course_users = User.find_by_sql(course_users_sql) || []
    @channels = list_of_channels || []
    @roles = fill_roles || {}
    @roles_friends = fill_roles_friends || {}
  end

  def fill_roles
    roles = nil

    ActiveRecord::Base.transaction do
      roles = Role.all.inject({}) do |acc, role|
        acc[role.to_s] = false
        acc
      end

      roles['admin'] = true if @user.admin?
      @user.user_course_associations.approved.group('role').count.each do |k,v|
        roles[Role[k].to_s] = true
      end
    end

    roles
  end

  def fill_roles_friends
    roles = nil

    ActiveRecord::Base.transaction do
      roles = Role.all.inject({}) do |acc, role|
        acc[role.to_s] = false
        acc
      end

      roles['admin'] = true if @user.admin?
    end

    roles
  end

  # Autentica usuário no canal de presença. Retorna o payload para ser
  # enviado ao cliente ou nil para caso de acesso negado.
  def presence_auth(channel_name, socket_id)
    if own_channel?(channel_name)
      payload = { :contacts => @channels }

      response_body = Pusher[channel_name].
        authenticate(socket_id,
                     :user_id => @user.id,
                     :user_info => payload )

      return response_body.stringify_keys!
    elsif can_subscribe?(channel_name)
      payload = { :name => @user.display_name,
        :thumbnail => @user.avatar.url(:thumb_24),
        :pre_channel => @user.presence_channel,
        :pri_channel => @user.private_channel_with(@contacts_by_pre[channel_name]),
        :roles => just_friends?(channel_name) ? @roles_friends : @roles }

      response_body = Pusher[channel_name].
        authenticate(socket_id,
                     :user_id => @user.id,
                     :user_info => payload )

      return response_body.stringify_keys!
    else
      return nil
    end
  end

  # Autentica usuário no canal de privado. Retorna o payload para ser
  # enviado ao cliente ou nil para caso de acesso negado.
  def private_auth(channel_name, socket_id)
    return nil unless can_subscribe?(channel_name)

    response_body = Pusher[channel_name].
      authenticate(socket_id)

    response_body
  end

  # Verifica se @user é dono do canal de presenca
  def own_channel?(channel_name)
    @user.presence_channel == channel_name
  end

  # Verifica se @user pode se increver em um determinado canal ou usuário.
  def can_subscribe?(channel_or_user)
    case channel_or_user
    when String
      own_channel?(channel_or_user) || @channels.include?(channel_or_user)
    when User
      @user == channel_or_user || @contacts.include?(channel_or_user)
    else
      false
    end
  end

  def just_friends?(channel)
    user = @contacts_by_pre[channel]
    !@course_users.include?(user)
  end

  protected

  def list_of_channels
    @contacts.collect do |contact|
      [contact.presence_channel, @user.private_channel_with(contact)]
    end.flatten!
  end

  # Retorna todos os contatos do chat. Isto inclui amigos e algumas pessoas
  # dos cursos que o usuário participa. Caso ele seja professor ou tutor num
  # curso todos os membros desse curso serão contatos no chat. Caso ele seja
  # um membro normal de um curso, todos os professores e tutores serão
  # contatos no chat.
  #
  # A legibilidade deste método está comprometida por questões de performance:
  # a lista de contatos é carregada num número de consultas constante.
  def list_of_contacts
    ActiveRecord::Base.transaction do
    # Condições para contatos (friendship)
    sql = <<-eos
     ((`friendships`.user_id = ?) AND ((friendships.status = 'accepted')))
    eos
    friends_cond = [sql, @user.id]
    friends_cond = ActiveRecord::Base.send(:sanitize_sql_array, friends_cond)

    # União de usuários amigos (friendship) e usuários do curso
    sql = <<-eos
     #{ self.course_users_sql }
     UNION
     SELECT `users`.* FROM `users` INNER JOIN
      `friendships` ON `users`.id = `friendships`.friend_id
      WHERE #{friends_cond}
    eos

    User.find_by_sql(sql)
    end
  end

  # SQL para usuários do curso
  def course_users_sql
    teacher_or_tutor = [ Role[:teacher].to_s, Role[:tutor].to_s ]
    member = Role[:member].to_s

    # Cursos nos quais ele é professor ou tutor
    teaching_courses = Course.select("courses.id").
      joins(:user_course_associations).
      where(:course_enrollments =>
            { :state => 'approved', :user_id => @user.id, :role => teacher_or_tutor }).all

    # Curso nos quais ele é membro
    enrolled_courses = Course.select("courses.id").
      joins(:user_course_associations).
      where(:course_enrollments =>
            { :state => 'approved', :user_id => @user.id, :role => member }).all

    # Condições para usuários de cursos
    sql = <<-eos
     `course_enrollments`.`state` = 'approved' AND
     `course_enrollments`.`user_id` != ? AND
        (
         course_enrollments.course_id IN (?) OR
         (course_enrollments.course_id IN (?)
          AND course_enrollments.role IN (?))
        )
    eos
    course_cond = [sql, @user.id, teaching_courses, enrolled_courses,
                   teacher_or_tutor]
    course_cond = ActiveRecord::Base.send(:sanitize_sql_array, course_cond)

    <<-eos
     SELECT `users`.* FROM `users` INNER JOIN
       `course_enrollments` ON
       `course_enrollments`.`user_id` = `users`.`id`
      WHERE #{course_cond}
    eos
  end

  # Indexa contatos por nome de canal de presença
  def build_index(contacts)
    contacts.inject({}) do |acc,contact|
      acc[contact.presence_channel] = contact
      acc
    end
  end
end
