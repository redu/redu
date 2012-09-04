class MessageCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe Message

  def after_create(message)
    expire_nav_account_for(message.recipient)
  end

  def after_update(message)
    if message.recipient_deleted_changed? || message.read_at_changed?
      expire_nav_account_for(message.recipient)
    end
  end

  def after_destroy(message)
    expire_nav_account_for(message.recipient)
  end
end
