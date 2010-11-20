class Ability
  include CanCan::Ability

  # Regras de authorization
  def initialize(user)
    if user.nil?
      can :preview do |object|
        object.published
      end
    else
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
