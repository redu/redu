class Ability
  include CanCan::Ability

  # Regras de authorization
  def initialize(user)
    # Aliases para acoes não padrão
    # Overall Manage
    alias_action :publish, :unpublish, :admin_members,
      :search_users_admin, :destroy_members, :to => :manage

    # Overall Read
    alias_action :rate, :to => :read

    # Environment
    alias_action :admin_courses, :to => :manage

    # Course
    alias_action :admin_spaces, :admin_members_request,
      :moderate_members_requests, :invite_members, :admin_manage_invitations,
      :admin_invitations, :destroy_invitations, :to => :manage
    alias_action :unjoin, :to => :read

    # Space
    alias_action :admin_subjects, :to => :manage
    #TODO action manage gerando recursividade
    alias_action :mural, :students_endless , :to => :read

    # Folder
    alias_action :do_the_upload, :upload, :rename,
      :destroy_folder, :destroy_file, :to => :manage
    alias_action :download, :to => :read

    # User
    alias_action :show_mural, :contacts_endless, :environments_endless, :to => :read

    alias_action :assume, :edit_account,
      :update_account, :invite, :activate, :deactivate,
      :account, :home, :my_wall, :to => :manage

    # Lecture
    alias_action :cancel, :unpublished, :to => :manage
    alias_action :download_attachment, :rate, :done,
      :to => :read
    alias_action :unpublished_preview, :to => :preview

    # Message
    alias_action :delete_selected, :to => :manage

    # Subject
    alias_action :cancel, :admin_lectures_order, :to => :manage
    alias_action :statuses, :mural, :to => :read

    # Presence
    alias_action :auth, :to => :manage
    alias_action :send_chat_message, :last_messages_with, :to => :subscribe_channel

    # Plan
    alias_action :confirm, :address, :pay, :upgrade, :to => :manage

    # Todos podem ver o preview
    can :preview, [Course, Environment], :published => true
    can :preview, Subject, :visible => true

    # Todos podem criar usuários
    can :create, User

    # Usuários logados podem
    unless user.nil?

      # Ter acesso ao 'Ensine', só usuários logados
      can :teach_index, :base

      # Gerencial
      can :manage, :all do |object|
        user.can_manage? object
      end

      # Usuário normal
      can :read, :all do |object|
        user.can_read? object
      end

      can :create, Environment

      # Course
      can :join, Course

      can :teach, Course do |course|
        user.teacher?(course)
      end

      can [:accept, :deny], Course do |course|
        assoc = user.get_association_with(course)
        !assoc.nil? and assoc.state == "invited"
      end

      # User
      can :read, User
      can :view_mural, User do |u|
        u.settings.view_mural == Privacy[:public] or
        (u.settings.view_mural == Privacy[:friends] && u.friends?(user))
      end

      # Space
      can :preview, Space do |space|
        user.can_read? space
      end

      # Seminar
      can :upload_multimedia, Seminar do |seminar|
        seminar.can_upload_multimedia?(seminar.lecture)
      end

      # Document
      can :upload_document, Document do |document|
        document.can_upload_document?(document.lecture)
      end

      can :subscribe_channel, User do |contact|
        Presence.new(user).contacts.include?(contact)
      end

      can :multiauth, User

      # My file
      cannot :upload_file, Myfile do |myfile|
        !myfile.can_upload_file?
      end

      # Join in a Course
      can :add_entry, Course do |course|
        course.can_add_entry?
      end

      # Plan (payment gateway)
      can :read, :success

      # Admin do environment ou teacher, caso o space não tenha owner
      can :take_ownership, Space do |space|
        user.can_manage?(space.course.environment) || \
          (space.owner.nil? && user.teacher?(space))
      end

      # Caso seja o Status de usuário, apenas ele mesmo ou seus amigos
      # podem criá-lo/respondê-lo.
      can [:create, :respond], [Status, Activity, Answer] do |status|
        # Caso seja no mural de um usuário
        ((status.statusable.class.to_s.eql? 'User') && \
         ((can? :manage, status.statusable) ||
          (can? :view_mural, status.statusable))) ||
          # Caso geral (Spaces, Subjects, etc.)
          (user.has_access_to? status.statusable)
      end

      # Parceiros
      can :contact, Partner
    end
  end
end
