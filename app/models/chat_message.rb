class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'

  scope :log, lambda { |time, limit|
    where('created_at >= ? AND (user_id = ? OR contact_id = ?)', time, self.user.id, self.user.id).limit(limit)
  }

end
