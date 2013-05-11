class Friendship < ActiveRecord::Base
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  def notificable?
    self.accepted?
  end

  def notify_request
    if requested?
      UserNotifier.delay(:queue => 'email').
        friendship_requested(user, friend)
    end
  end
end
