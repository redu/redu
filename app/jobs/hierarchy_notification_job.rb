class HierarchyNotificationJob
  include EnrollmentVisNotification
  attr_accessor :enrollment, :type
  attr_reader :logger

  def initialize(enrollment, type)
    @enrollment = enrollment
    @type = type
  end

  def perform
    send_to_vis(enrollment, type)
  end
end
