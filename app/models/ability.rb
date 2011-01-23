class Ability
  include CanCan::Ability

  # Regras de authorization
  def initialize(user)
    # Aliases para acoes não padrão
    # Overall Manage
    alias_action :publish, :unpublish, :admin_members, :admin_bulletins,
      :search_users_admin, :to => :manage

    # Overall Read
    alias_action :vote, :rate, :more, :to => :read

    # Environment
    alias_action :admin_courses, :destroy_members, :to => :manage

    # Course
    alias_action :admin_spaces, :admin_members_request,
      :moderate_members_requests, :to => :manage
    alias_action :unjoin, :to => :read

    # Space
    alias_action :admin_events, :moderate_bulletins, :moderate_events,
      :look_and_feel, :set_theme, :new_space_admin, :to => :manage
    #TODO action manage gerando recursividade

    # Folder
    alias_action :do_the_upload, :upload, :update_permissions, :rename,
      :destroy_folder, :to => :manage
    alias_action :download, :feed, :feed_warning, :to => :read

    # Post
    alias_action :monitored, :search, :to => :read

    # Event
    alias_action :ical, :past, :notify, :day, :to => :read

    # Status
    alias_action :respond, :to => :read

    # User
    alias_action :follows, :learning, :followers, :teaching,
      :show_log_activity, :log, :welcome_complete, :list_subjects,
      :show_log_activity, :activity_xml, :download_curriculum, :to => :read

    alias_action :assume, :metro_area_update, :edit_account,
      :update_account, :edit_pro_details, :update_pro_details,
      :invite, :activate, :deactivate, :groups, :statistics,
      :change_profile_photo, :crop_profile_photo,
      :upload_profile_photo, :activity_xml, :annotations, :activate, :deactivate,
      :to => :manage

    # Lecture
    alias_action :embed_content, :upload_video, :cancel, :unpublished,
      :waiting, :to => :manage
    alias_action :download_attachment, :rate, :sort_lesson,
      :to => :read
    alias_action :unpublished_preview, :to => :view

    # Exam
    alias_action :cancel, :add_question, :remove_question, :sort_question,
      :questions_database, :unpublished, :unpublished_preview,
      :to => :manage
    alias_action :results, :answer, :compute_results, :search, :published,
      :get_query, :review_question, :to => :read

    # Message
    alias_action :delete_selected, :more, :to => :manage

    # Subject
    alias_action :lazy, :cancel, :edit_resources, :update_resources,
      :change_assets_order, :to => :manage
    alias_action :statuses, :next, :previous, :attend, :to => :read
    alias_action :infos, :enroll, :to => :preview

    # Plan
    alias_action :confirm, :address, :pay, :to => :manage

    # Todos podem ver o preview
    can :view, :all do |object|
      object.published?
    end

    # Todos podem criar usuários
    can :create, User

    # Usuários logados podem
    unless user.nil?
      # Gerencial
      can :manage, :all do |object|
        user.can_manage? object
      end

      # Usuário normal
      can :read, :all do |object|
        user.can_read? object
      end
      can :preview, [Course, Environment], :published => true

      can :create, Environment
      can :join, Course

      # User
      can :follow, User
      can :read, User

      # Subject
      can :preview, Subject do |subject|
        subject.published? && user.has_access_to?(subject.space)
      end
      can :unenroll, Subject do |subject|
        subject.published? && user.has_access_to?(subject)
      end

      # Admin do environment ou teacher, caso o space não tenha owner
      can :take_ownership, Space do |space|
        user.can_manage?(space.course.environment) || \
          (space.owner.nil? && user.teacher?(space))
      end

      # Caso seja o Status de usuário, apenas ele mesmo pode criá-lo.
      can :create, Status do |status|
        ((status.statusable.class.to_s.eql? 'User') && \
         (user == status.statusable)) ||
          # Caso geral (Spaces, Subjects, etc.)
          (user.has_access_to? status.statusable)
      end
    end
  end

end
