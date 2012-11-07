class BaseDoorkeeper
  include Untied::Publisher::Doorkeeper

  def initialize
    %w(user space environment course space subject lecture user_environment_association user_course_association enrollment).
      each do |klass|
      puts klass.classify.constantize
      watch klass.classify.constantize, :after_create, :after_update
    end
    watch UserSpaceAssociation, :after_create, :after_destroy
  end
end
