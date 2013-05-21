# -*- encoding : utf-8 -*-
class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'
  has_many :chat_message_associations
  has_many :chats, :through => :chat_message_associations

  scope :log_by_time_and_limit, lambda { |curr_user ,contact, time, limit|
    where('created_at >= ? AND ((user_id = ? AND contact_id = ?) OR (user_id = ? AND contact_id = ?))',
          time, curr_user.id, contact.id, contact.id, curr_user.id).
          order('created_at DESC').limit(limit)
  }

  def self.log(curr_user, contact, time=1.day.ago, limit=20)
    logs = self.log_by_time_and_limit(curr_user, contact, time, limit)
    logs.sort!{|a, b| a.created_at <=> b.created_at}
    logs.collect do |chat|
      {:name => chat.user.display_name, :user_id => chat.user.id,
        :text => chat.message, :thumbnail => chat.user.avatar.url(:thumb_24),
        :time => self.format_time(chat.created_at)}
    end
  end

  def self.format_time(time)
    if time.day == Time.now.day
      time.strftime("hoje, %H:%M")
    else
      time.strftime("ontem, %H:%M")
    end
  end
end
