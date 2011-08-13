class StatusUserAssociation < ActiveRecord::Base
  belongs_to :status
  belongs_to :user
end
