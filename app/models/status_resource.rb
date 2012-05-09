class StatusResource < ActiveRecord::Base
  belongs_to :status
  validates_presence_of :link
end
