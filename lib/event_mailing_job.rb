class EventMailingJob < Struct.new(:user, :event)
  def perform
    UserNotifier.deliver_event_notification(user, event)
  end
end