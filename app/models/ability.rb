class Ability
  include CanCan::Ability

  # Regras de authorization
  def initialize(user)
    # Aliases para acoes não padrão
    # Overall Manage
    alias_action :publish, :unpublish, :admin_members, :admin_bulletins, :search_users_admin, :to => :manage

    # Overall Read
    alias_action :vote, :rate, :more, :to => :read

    # Environment
    alias_action :admin_courses, :destroy_members, :to => :manage

    # Course
    alias_action :admin_spaces, :admin_members_request, :moderate_members_requests, :to => :manage
    alias_action :unjoin, :to => :read

    # Space
    alias_action :admin_requests, :admin_events, :moderate_bulletins, :moderate_events, :moderate_requests, :look_and_feel, :set_theme, :new_space_admin, :to => :manage
    #TODO action manage gerando recursividade

    # Folder
    alias_action :do_the_upload, :upload, :update_permissions, :rename, :destroy_folder, :to => :manage
    alias_action :download, :feed, :feed_warning, :to => :read

    # Post
    alias_action :monitored, :search, :to => :read

    # Event
    alias_action :ical, :past, :notify, :day, :to => :read

    # Status
    alias_action :respond, :to => :read

    # Todos podem ver o preview
    can :preview, :all do |object|
      object.published?
    end

    can :create, Environment

    unless user.nil?
      # Gerencial
      can :manage, :all do |object|
        user.can_manage? object
      end

      can :create, Bulletin do |bulletin|
        user.can_manage?(bulletin.bulletinable) || user.tutor?(bulletin.bulletinable)
      end

      # Usuário normal
      can :read, :all do |object|
        if (object.class.to_s.eql? 'Folder') || (object.class.to_s.eql? 'Forum') ||
          (object.class.to_s.eql? 'Topic') || (object.class.to_s.eql? 'SbPost')
          user.has_access_to?(object)
        else
          object.published? && user.has_access_to?(object)
        end
      end

    end
  end

end
