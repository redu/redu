class Friendship < ActiveRecord::Base
  has_many :logs, :as => :logeable
end
