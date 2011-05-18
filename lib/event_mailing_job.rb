class EventMailingJob < Struct.new(:user, :event)
  def perform
    UserNotifier.event_notification(user, event).deliver
  end
end
