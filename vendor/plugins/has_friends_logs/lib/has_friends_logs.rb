class Friendship < ActiveRecord::Base
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  def notificable?
    self.accepted?
  end

  def notify_request
    UserNotifier.friendship_requested(user, friend).deliver
  end
end
