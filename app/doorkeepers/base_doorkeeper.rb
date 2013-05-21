# -*- encoding : utf-8 -*-
class BaseDoorkeeper
  include Untied::Publisher::Doorkeeper

  def initialize
    %w(space course space subject lecture user_environment_association
       user_course_association).each do |klass|
      watch klass.classify.constantize, :after_create, :after_update, :after_destroy
    end

    watch Enrollment, :after_destroy, :after_create

    watch Environment, :after_create, :after_update, :after_destroy,
      :represent_with => Untied::EnvironmentRepresenter
    watch User, :after_create, :after_update, :after_destroy,
      :represent_with => Untied::UserRepresenter
    watch UserSpaceAssociation, :after_create, :after_destroy
  end
end
