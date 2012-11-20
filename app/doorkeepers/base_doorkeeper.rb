class BaseDoorkeeper
  include Untied::Publisher::Doorkeeper

  def initialize
    %w(space environment course space subject lecture user_environment_association
       user_course_association enrollment).each do |klass|
      watch klass.classify.constantize, :after_create, :after_update
    end

    watch User, :after_create, :after_update, :represent_with => Untied::UserRepresenter
    watch UserSpaceAssociation, :after_create, :after_destroy
  end
end
