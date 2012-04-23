module Api
  class Ability
    include CanCan::Ability
    include Api::EnvironmentAbility
    include Api::CourseAbility
    include Api::UserAbility

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
