class Ability
  include CanCan::Ability

  # Regras de authorization
  def initialize(user)
    # Todos podem ver o preview
    can :preview, :all do |object|
      object.published?
    end

    unless user.nil?
      # Gerencial
      can :manage, :all do |object|
        user.can_manage? object
      end
      # Usuário normal
      can :read, :all do |object|
        object.published && user.has_access_to?(object)
      end
    end
  end

end
