module Api
  class Ability
    include CanCan::Ability
    include Api::EnvironmentAbility
    include Api::CourseAbility
    include Api::CourseEnrollmentAbility
    include Api::SpaceAbility
    include Api::UserAbility
    include Api::StatusAbility

    def initialize(user)
      can :read, :error
      execute_rules(user)
    end

    protected

    def execute_rules(user)
      methods.select { |m| m =~ /.+_abilities$/ }.each do |m|
        send(m, user)
      end
    end
  end
end
