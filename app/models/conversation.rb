class Conversation < ActiveRecord::Base
  attr_accessible :recipient_id, :sender_id
end
