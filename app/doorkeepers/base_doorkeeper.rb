class BaseDoorkeeper
  include Untied::Publisher::Doorkeeper

  def initialize
    watch User, :after_create, :after_update
  end
end
