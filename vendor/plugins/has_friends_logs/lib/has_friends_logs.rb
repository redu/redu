class Friendship < ActiveRecord::Base
  has_many :logs, :as => :logeable, :order => "created_at DESC",
    :dependent => :destroy

  def notificable?
    self.accepted?
  end
end
