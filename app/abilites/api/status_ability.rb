module Api
  module StatusAbility
    extend ActiveSupport::Concern
    
    module InstanceMethods
      def status_abilities(user)
        if user
          can :read, Status do |s|
            user == s.user
          end
        end
      end
    end
  end
end
